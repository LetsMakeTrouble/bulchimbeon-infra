#!/usr/bin/env sh
# 배포 한 방 — 최신화 → 서브모듈 정렬 → .env 점검 → 이미지 빌드 → 기동.
#
#   sh scripts/deploy.sh                                  # 커밋에 박힌 서브모듈 핀 그대로
#   sh scripts/deploy.sh --frontend feat/docker-serving   # 프론트만 다른 브랜치로
#   sh scripts/deploy.sh --backend main --frontend woojin  # 둘 다 지정
#   sh scripts/deploy.sh --no-pull                        # 지금 받아 둔 상태 그대로 빌드만
#
# ⛔ **`--backend` / `--frontend` 로 옮긴 상태를 커밋하지 마라.** 서브모듈 핀은 이 저장소의
#    커밋 하나가 "프론트 A + 백엔드 B" 조합을 기록하는 장치다. 임의 브랜치를 커밋해 넣으면
#    그 기록이 깨져 롤백할 때 어느 조합으로 돌아가는지 알 수 없게 된다.
#    스크립트는 끝에서 포인터가 움직였는지 확인하고 경고한다 — `git add` 는 절대 하지 않는다.

# --------------------------------------------------------------------------------------
# ⛔ `source` / `.` 로 실행하지 마라 (`init-env.sh` 와 같은 이유).
#    `set -e` 와 `exit` 가 호출한 셸에 그대로 적용돼, 실패하는 순간 SSH 세션이 함께 죽는다.
# --------------------------------------------------------------------------------------
_sourced=0
[ -n "${BASH_SOURCE:-}" ] && [ "${BASH_SOURCE:-}" != "${0:-}" ] && _sourced=1
case "${ZSH_EVAL_CONTEXT:-}" in *:file:*) _sourced=1 ;; esac
if [ "$_sourced" = 1 ]; then
  echo "⛔ source 로 실행하지 마라 — 실패하면 로그인 셸까지 함께 죽는다." >&2
  echo "   이렇게 실행해라:  sh scripts/deploy.sh" >&2
  return 1
fi

set -eu

BACKEND_REF=''
FRONTEND_REF=''
PULL=1

while [ $# -gt 0 ]; do
  case "$1" in
    --backend)  [ $# -ge 2 ] || { echo "⛔ --backend 뒤에 브랜치명이 없다." >&2; exit 1; }
                BACKEND_REF="$2"; shift 2 ;;
    --frontend) [ $# -ge 2 ] || { echo "⛔ --frontend 뒤에 브랜치명이 없다." >&2; exit 1; }
                FRONTEND_REF="$2"; shift 2 ;;
    --no-pull)  PULL=0; shift ;;
    -h|--help)  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "⛔ 모르는 옵션: $1" >&2; echo "   sh scripts/deploy.sh --help" >&2; exit 1 ;;
  esac
done

# 어느 디렉터리에서 불러도 리포 루트에서 돈다. compose 의 상대 빌드 컨텍스트가
# `docker-compose.yml` 위치 기준이라, cd 하지 않으면 서브모듈 경로를 못 찾는다.
ROOT=$(git rev-parse --show-toplevel) || {
  echo "⛔ git 저장소 안이 아니다. bulchimbeon-infra 안에서 실행해라." >&2; exit 1
}
cd "$ROOT"

step() { echo; echo "── $* ──"; }

# --------------------------------------------------------------------------------------
step "1/6  작업 상태 확인"

# ⚠️ 서브모듈은 제외하고 본다(`--ignore-submodules`). 직전 배포에서 --frontend 를 썼다면
#    포인터가 핀과 다른 상태로 남아 있는데, 그건 4단계가 어차피 정리한다.
#    여기서 막으면 "정상적으로 쓰던 사람이 매번 걸리는" 검사가 된다.
if [ -n "$(git status --porcelain --ignore-submodules)" ]; then
  if [ "$PULL" = 1 ]; then
    echo "⛔ 커밋하지 않은 변경이 있다. rebase 가 이것을 밟고 지나간다." >&2
    git status --short --ignore-submodules >&2
    echo >&2
    echo '   커밋하거나 `git stash` 로 치운 뒤 다시 실행해라.' >&2
    echo '   지금 상태 그대로 빌드만 하려면: sh scripts/deploy.sh --no-pull' >&2
    exit 1
  fi
  echo "⚠ 커밋하지 않은 변경이 있다 — --no-pull 이라 그대로 빌드한다."
  git status --short --ignore-submodules | sed 's/^/  /'
fi
echo "· 브랜치: $(git rev-parse --abbrev-ref HEAD)  ($(git rev-parse --short HEAD))"

# --------------------------------------------------------------------------------------
step "2/6  최신화"

if [ "$PULL" = 0 ]; then
  echo "· --no-pull — 건너뛴다"
elif git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
  # ⚠️ merge 가 아니라 rebase 다. 배포 저장소의 이력은 "어떤 조합을 배포했는가" 의
  #    목록이라 병합 커밋이 끼면 읽기 어려워진다.
  git pull --rebase
  echo "· 지금: $(git rev-parse --short HEAD)"
else
  echo "⚠ 업스트림이 없는 브랜치라 pull 을 건너뛴다."
fi

# --------------------------------------------------------------------------------------
step "3/6  서브모듈을 커밋에 박힌 핀으로 정렬"

# ⚠️ 오버라이드보다 **먼저** 돌려야 한다. 순서가 바뀌면 방금 체크아웃한 브랜치를
#    이 명령이 핀으로 되돌려 놓고, 증상은 "옵션을 줬는데 안 먹는다" 로만 나타난다.
git submodule sync --quiet --recursive
git submodule update --init --recursive
git submodule status | sed 's/^/  /'

# --------------------------------------------------------------------------------------
step "4/6  서브모듈 브랜치 지정"

checkout_ref() {
  path="$1"; ref="$2"
  echo "· $path → $ref"
  # 로컬에 없는 브랜치일 수 있으니 먼저 받아 온다. 원격 상태를 그대로 쓰려고
  # 로컬 브랜치명이 아니라 FETCH_HEAD 를 체크아웃한다 — 오래된 로컬 브랜치가
  # 조용히 쓰이는 것을 막는다.
  git -C "$path" fetch --quiet origin "$ref" || {
    echo "⛔ $path 에 '$ref' 브랜치가 없다." >&2; exit 1
  }
  git -C "$path" checkout --quiet --detach FETCH_HEAD
  echo "  $(git -C "$path" log --oneline -1)"
}

if [ -z "$BACKEND_REF" ] && [ -z "$FRONTEND_REF" ]; then
  echo "· 지정 없음 — 핀 그대로 간다"
fi
# ⚠️ `[ -n "$REF" ] && checkout_ref …` 로 쓰지 마라. 참조가 비면 그 줄의 종료 코드가 1 이 되고
#    `set -e` 가 스크립트를 거기서 끝낸다 — 옵션을 안 준 게 실패로 처리된다.
if [ -n "$BACKEND_REF" ];  then checkout_ref bulchimbeon-backend  "$BACKEND_REF"; fi
if [ -n "$FRONTEND_REF" ]; then checkout_ref bulchimbeon-frontend "$FRONTEND_REF"; fi

# 프론트 `main` 은 구현이 걷어내진 뼈대라 Dockerfile 이 없다. 여기서 막지 않으면
# 몇 분 뒤 docker 가 뱉는 "failed to read dockerfile" 만 보고 원인을 되짚어야 한다.
if [ ! -f bulchimbeon-frontend/Dockerfile ]; then
  echo
  echo "⛔ bulchimbeon-frontend 에 Dockerfile 이 없다 — 이 브랜치로는 web 을 빌드할 수 없다." >&2
  echo "   현재: $(git -C bulchimbeon-frontend log --oneline -1 2>/dev/null || echo '체크아웃 안 됨')" >&2
  echo "   배포용 브랜치를 지정해라:" >&2
  echo "     sh scripts/deploy.sh --frontend feat/docker-serving" >&2
  exit 1
fi

# --------------------------------------------------------------------------------------
step "5/6  .env 점검"

# 비밀값은 이미 있으면 건드리지 않는다. 처음이면 만들어 주고, 빈 칸이 남아 있으면
# 여기서 멈춘다 — compose 가 `${VAR:?}` 로 어차피 거부하므로 먼저 걸러 내는 편이 낫다.
sh scripts/init-env.sh

# --------------------------------------------------------------------------------------
step "6/6  빌드 · 기동"

# 빌드를 먼저 끝낸다. 실패하면 돌고 있는 컨테이너를 건드리기 전에 멈춘다.
#
# ⚠️ **서비스를 하나씩 부른다.** `docker compose build` 는 세 이미지를 **동시에** 만드는데,
#    그러면 백엔드의 `chown -R /app`(I/O)과 프론트의 `npm ci`·`vite build`(CPU·메모리)가
#    같은 순간에 물린다. 작은 LXC·VM 에서는 이때 메모리가 천장을 치고, 스왑이 없으면
#    커널이 OOM 킬 대신 페이지 회수로 겉돌아 **그대로 멈춘 것처럼 보인다.**
#    한 번에 하나면 피크가 낮아진다. 캐시는 그대로 쓰므로 총 시간은 거의 같다.
#
# `migrate` 는 `api` 와 빌드 컨텍스트가 같아 뒤에 두면 전부 캐시 히트다.
for svc in api web migrate; do
  echo "· build $svc"
  docker compose build "$svc"
done

docker compose up -d

echo
docker compose ps

# --------------------------------------------------------------------------------------
echo
if [ -n "$(git status --porcelain -- bulchimbeon-backend bulchimbeon-frontend)" ]; then
  echo "⚠ 서브모듈 포인터가 커밋된 핀과 다르다 (브랜치를 지정했으니 정상이다)."
  git status --short -- bulchimbeon-backend bulchimbeon-frontend | sed 's/^/  /'
  echo "  ⛔ 이 상태를 커밋하지 마라. 되돌리려면: git submodule update --init --recursive"
fi

echo
echo "✅ 기동했다. api 헬스체크는 20초쯤 뒤에 green 이 된다."
echo
echo "   docker compose logs -f api      # 로그"
echo "   docker compose ps               # 상태"
echo "   docker compose down             # 정지 (볼륨은 남는다)"
