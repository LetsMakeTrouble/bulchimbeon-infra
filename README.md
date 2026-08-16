# 불침번 (Bulchimbeon)

> **당신이 자는 동안, 협업은 계속됩니다.**
>
> 팀에서 한 명은 깨어 있어야 합니다. 이제 그 불침번을 AI가 섭니다.

시차가 큰 글로벌 팀을 위한 **비동기 Q&A 협업 웹앱**입니다.

해외 파트너가 올려둔 프로젝트 지식을 근거로 AI가 **각자의 언어로** 즉답하고,
답변마다 **매칭률(%)** 을 함께 보여줍니다.
확신이 부족한 답변은 담당자에게 넘겨 검토를 받고, 확정된 답은 지식으로 영구 편입됩니다.

이 저장소는 불침번을 이루는 **서비스들을 한데 모아 배포하는 곳**입니다.
실제 코드는 서브모듈로 연결된 백엔드·프론트엔드 저장소에 있습니다.

---

## 어떤 문제를 푸나요

### 24시간 핑퐁

질문 하나에 되물음이 한 번 더 오가면 **이틀**이 걸립니다.

```
월 10:00 (서울)   지수: "API 응답에 user_id 포함되나요?"
화 02:00 (서울)   마이크 출근: "포함돼요. 어떤 포맷이 필요하세요?"
화 09:00 (서울)   지수 답변
수 02:00 (서울)   마이크 확인                    → 🔥 이틀 소요
```

**질문하는 쪽**은 답을 기다리는 동안 작업이 막히고, 참다못해 추측으로 진행했다가 다시 작업합니다.
영어 문서가 있어도 확신이 서지 않아 결국 또 물어보게 됩니다.

**답하는 쪽**은 비슷한 질문에 매번 응답해야 하고, 퇴근 후에도 노트북을 놓기 어렵습니다.
상시 대기 스트레스가 쌓입니다.

### 그런데 답은 이미 있습니다

시차 때문에 막히는 질문의 **70~80%는 답이 이미 존재합니다.** 문서 안에, 혹은 지난 대화 속에요.

사람이 자는 건 어쩔 수 없지만, **협업까지 멈출 필요는 없습니다.**

## 어떻게 동작하나요

| 시점 | 무슨 일이 일어나나요 |
|---|---|
| 🌙 퇴근 전 | 담당자가 프로젝트 자료와 응답 지침을 올리고 방해금지 시간을 켭니다 |
| ☀️ 업무 시간 | 한국 팀원이 **한국어로** 질문합니다 |
| 🤖 즉답 | AI가 **매칭률과 근거 링크**를 붙여 답합니다 |
| 📱 확인 | 매칭률이 낮으면 담당자에게 확인 카드가 전달되고, 담당자는 30초 안에 판단합니다 |
| ♻️ 편입 | 확정된 답변이 공식 Q&A로 저장됩니다 — **같은 질문에 두 번 다시 24시간이 걸리지 않습니다** |

### 1. 확신이 없으면 지어내지 않아요

모든 답변에 **매칭률**(근거가 얼마나 충족되는지, 0~100)을 계산해 세 갈래로 나눕니다.

| 등급 | 매칭률 | 처리 방식 |
|---|---|---|
| 🟢 **즉답** | 80 이상 | 근거 인용과 함께 바로 답합니다 |
| 🟡 **확인 대기** | 50~79 | 답을 주되 "담당자 확인 대기" 표시를 붙입니다 |
| 🔴 **보류** | 50 미만 | 답하지 않고 담당자에게 넘깁니다 |

점수와 무관하게 **무조건 🔴로 넘기는 조건**도 있습니다.
근거끼리 충돌하거나, 정보가 아예 없거나, 승인이 필요하거나, 권한 위험이 있거나,
번역 과정에서 의미가 손실될 위험이 큰 경우입니다.

### 2. 답이 틀리면 어떡하나요 — 4겹 방어

할루시네이션을 완전히 없앨 수는 없습니다. 대신 **네 겹으로 막고, 뚫려도 피해가 남지 않게** 설계했습니다.

| 겹 | 단계 | 방어 방식 |
|---|---|---|
| 1겹 | 생성 차단 | **인용 강제** — 근거 문서에 없는 내용은 답변 생성 자체를 막습니다 |
| 2겹 | 발화 전 필터 | 매칭률이 낮으면 **답변을 보류**합니다. 애매하면 틀린 답 대신 사람에게 넘깁니다 |
| 3겹 | 발화 후 검증 | 🟡 미확인 뱃지 + 담당자 검토 + **질문자 크로스체크(✅/❌)** |
| 4겹 | 사후 보정 | 크로스체크 실적으로 주제별 임계값을 조정합니다. 자주 틀리는 영역은 점점 보수적으로 |

뚫렸을 때 최악의 결과도 "오답을 믿고 재작업"이 아니라 **"참고 답변을 재확인"** 입니다.
모든 답변에 근거 원문이 붙고, 확정 전에는 참고용임이 계속 표시되기 때문이에요.
**서비스가 없을 때보다 나빠지는 경로가 없습니다.**

### 3. 참고자료로 시작해서, 사람이 확정해요

AI가 내놓은 답은 전부 **"근거가 딸린 참고자료"** 입니다. 확정 답변이 아니에요.

확정으로 올라가는 길은 두 가지뿐입니다.

1. **담당자가 승인하거나 수정**했을 때
2. **질문자가 실제로 써보고 맞았다고 확인**했을 때

답변의 정오를 가장 먼저 아는 사람은 담당자가 아니라 질문자입니다.
그래서 답변 아래에 **✅ 맞았음 / ❌ 달랐음** 버튼을 두어,
**담당자를 깨우지 않고도 검증이 일어나게** 했습니다.

❌ 가 눌리면 담당자에게 전달되어 재검토 대상이 되고, 같은 근거를 쓴 다른 답변도 함께 살펴봅니다.

### 4. 한국어로 묻고, 영어로 전달해요

지식과 담당자는 영어, 질문과 답변은 한국어입니다.
담당자에게 넘어갈 때는 그냥 옮기지 않고 **배경 → 질문 → 선택지** 순으로 정리해서 전달합니다.
담당자가 맥락을 다시 찾아보지 않고도 바로 판단할 수 있게 하기 위해서예요.

질문 원문과 번역문은 **둘 다 보존**되므로, 언제든 원문을 확인할 수 있습니다.

### 5. 담당자가 알림을 통제해요

퇴근 후에 오는 알림은 슬랙 DM과 성격이 다릅니다.

| | 슬랙 DM | 불침번 |
|---|---|---|
| 담당자가 할 일 | 맥락 파악 → 문서 뒤지기 → 답변 작성 | AI가 정리한 답변과 근거를 **읽고 체크** |
| 발생 빈도 | 질문 10개 전부 | **2~3개만** (나머지는 즉답으로 해결) |
| 노동의 성격 | 답변 작성 | 검토 판단 |

여기에 담당자가 직접 통제할 수단을 더했습니다.

- **방해금지 시간** — 지정한 시간대에는 알림이 오지 않고, 그동안의 질문은 브리핑으로 묶여 전달됩니다
- **긴급도 분류** — 급하지 않은 질문은 즉시 알리지 않고 출근 시간에 맞춰 모아서 전달합니다
- **🌙 출근 후 처리** — 담당자가 판단을 미룰 권리도 갖습니다

## 주요 기능

| 영역 | 내용 |
|---|---|
| **프로젝트·지식 관리** | 프로젝트 생성과 초대 코드 참여, 문서 업로드와 버전 관리(활성/대체/만료), 프로젝트별 응답 지침, 매칭률 임계값·가중치 설정, Notion·GitHub 원본 연동 |
| **질문 접수·다국어** | 질문 원문과 번역문 동시 보존, 답변 언어 선택, 근거 원문 열람 |
| **근거 검색·답변 생성** | 프로젝트 경계 안의 활성 문서와 공식 Q&A만 검색, 주장마다 근거 연결, 근거 없는 문장은 출력에서 제거 |
| **신뢰 등급·확인 워크플로** | 매칭률 계산과 🟢🟡🔴 분기, 담당자 확인 카드 큐(🔴 우선·오래된 순), 승인·수정·반려 처리 |
| **알림·이력·지식 환류** | 확정/정정/반려 알림, 공식 Q&A 편입과 재사용, 처리 과정 타임라인 기록 |
| **멤버·권한** | 멤버 초대와 역할 관리(질문자·뷰어·담당자), 담당자 교체와 대기 항목 이관 |
| **피드백·질문 목록** | 답변 정확도 피드백, 상태·긴급·기간 조건 검색, 질문 상세 이력과 유사 질문 |

## 다른 서비스와 무엇이 다른가요

| 서비스 | 하는 일 | 차이 |
|---|---|---|
| Tettra (Kai) | 못 찾은 질문을 전문가에게 라우팅 | 단일 회사 · 영어 전용 · Slack 종속 |
| Personal AI | 매칭률 기반 자동응답 | 개인 메시징용, 협업·시차 개념 없음 |
| Notion AI Q&A | 워크스페이스 지식 기반 답변 | 답이 없으면 일반론으로 채움, 사람에게 넘기는 경로 없음 |

불침번의 자리는 **답이 없을 때 시작되는 워크플로**입니다.
다국어 비대칭 처리, 시차를 아는 핸드오프, 참고에서 확정으로 가는 상태 모델,
그리고 **쓸수록 우리 팀 사정을 알아가는 진화**가 함께 묶인 조합입니다.

## 저장소 구성

불침번은 세 개의 저장소로 나뉘어 있어요.

| 저장소 | 역할 |
|---|---|
| [`bulchimbeon-backend`](https://github.com/LetsMakeTrouble/bulchimbeon-backend) | FastAPI API 서버. 검색·답변 파이프라인, 등급 판정, 데이터 모델 |
| [`bulchimbeon-frontend`](https://github.com/LetsMakeTrouble/bulchimbeon-frontend) | React 웹 화면. 질문 · 확인 카드 큐 · 문서함 |
| **`bulchimbeon-infra`** (여기) | 위 둘을 묶어 함께 띄우는 배포 설정 |

앞의 둘은 이 저장소에 **서브모듈**로 연결되어 있습니다.
각 서비스는 자기 저장소에서 독립적으로 개발하고, 이곳에서는 **어떤 버전끼리 묶어 배포할지**를 관리합니다.

## 시작하기

### 클론

서브모듈이 있으므로 `--recurse-submodules` 를 꼭 붙여주세요.

```bash
git clone --recurse-submodules https://github.com/LetsMakeTrouble/bulchimbeon-infra.git
cd bulchimbeon-infra
```

이미 옵션 없이 받으셨다면 아래로 채울 수 있어요.

```bash
git submodule update --init --recursive
```

### 띄우기

배포는 한 줄입니다. 최신화 → 서브모듈 정렬 → `.env` 점검 → 빌드 → 기동을 순서대로 합니다.

```bash
sh scripts/deploy.sh
```

| 단계 | 하는 일 |
|---|---|
| 1 | 커밋하지 않은 변경이 있으면 멈춥니다 — rebase 가 그것을 밟고 지나가니까요 |
| 2 | `git pull --rebase` |
| 3 | 서브모듈을 **커밋에 박힌 핀으로** 되돌립니다 |
| 4 | `--backend` · `--frontend` 를 줬다면 그 브랜치로 옮깁니다 |
| 5 | `.env` 점검 — 없으면 만들고, 빈 칸이 남았으면 멈춥니다 |
| 6 | 이미지를 **하나씩** 빌드한 뒤 `up -d` |

6단계에서 서비스를 한 번에 하나씩 부르는 건 취향이 아닙니다. `docker compose build` 는
세 이미지를 동시에 만드는데, 그러면 백엔드의 `chown -R /app`(I/O)과 프론트의
`npm ci`·`vite build`(CPU·메모리)가 같은 순간에 물립니다. 메모리가 빠듯한 LXC·VM 에서는
이때 천장을 치고, **스왑이 없으면 커널이 OOM 킬 대신 페이지 회수로 겉돌아
멈춘 것처럼 보입니다.** 캐시는 그대로 쓰므로 총 시간은 거의 같습니다.

```bash
sh scripts/deploy.sh --frontend woojin                # 서브모듈 브랜치 지정
sh scripts/deploy.sh --no-pull                        # 지금 받아 둔 상태 그대로 빌드
sh scripts/deploy.sh --help
```

옵션을 주지 않으면 **이 저장소 커밋에 기록된 조합 그대로** 뜹니다.
브랜치를 지정하면 끝에서 포인터가 움직였다고 경고하는데, 스크립트는 `git add` 를 하지
않으니 그 상태만 커밋하지 않으면 됩니다.

| 서비스 | 역할 |
|---|---|
| `db` | `pgvector/pgvector:pg18`. 호스트 포트를 열지 않습니다 |
| `migrate` | `alembic upgrade head` 를 돌리고 종료하는 원샷. 여기서 실패하면 `api` 가 시작하지 않습니다 |
| `api` | FastAPI. 모든 경로가 `/api/v1` 아래에 있습니다 |
| `web` | 프론트 정적 번들 (nginx) |

#### `.env` 만 따로 만들려면

`deploy.sh` 5단계가 부르는 것과 같은 스크립트입니다. 생성 가능한 비밀값 4개를 채우고,
직접 넣어야 하는 것(`OPENAI_API_KEY`)과 눈으로 확인할 것(공개 도메인)을 짚어줍니다.

```bash
sh scripts/init-env.sh
```

이미 값이 있는 키는 **덮어쓰지 않으므로** 몇 번을 다시 돌려도 안전합니다.
특히 `INTEGRATION_ENCRYPTION_KEY` 는 바뀌면 DB 에 암호화해 둔 Notion·GitHub 토큰을
복호화할 수 없게 되어 연동을 전부 다시 등록해야 합니다.

### 데모 계정으로 로그인

띄운 직후의 DB 는 **비어 있습니다.** `deploy.sh` 는 시드를 돌리지 않으므로 계정도
프로젝트도 없습니다. 데모 데이터는 백엔드 시드 스크립트가 넣습니다.

```bash
docker compose exec api python scripts/seed.py --reset
```

이력·지표까지 채우려면 `--with-history` 를 더합니다. 실 LLM 을 전제하고 25~30분,
약 $1.3 이 듭니다. **발표 당일 말고 전날 채워 두세요.**

```bash
docker compose exec api python scripts/seed.py --reset --with-history
```

시드가 만드는 계정은 셋입니다. 프로젝트는 `GlobalMart JP Launch` 하나이고,
세 계정 모두 그 프로젝트에 이미 들어가 있습니다.

| 이메일 | 이름 | 역할 | 화면에서 보이는 것 |
|---|---|---|---|
| `mike@devcorp.example` | Mike Chen | 담당자 (`answerer`) | 확인 카드 인박스 · 브리핑 · 문서함 · 지표 · 설정 |
| `jisoo@globalmart.example` | 지수 | 질문자 (`asker`) | 질문하기 · 내 질문 이력 · ✅/❌ 크로스체크 |
| `minjun@globalmart.example` | 민준 | 질문자 (`asker`) | 위와 같음 (두 번째 질문자) |

**비밀번호는 셋 다 `demo1234!` 입니다.** 심사·시연용 고정값이라 `.env` 의
`DEMO_PASSWORD` 도 이 값으로 둡니다 (`init-env.sh` 는 이 키를 무작위로 만들지 않습니다).

⚠️ 공개된 비밀번호이므로 **담당자 계정에 누구나 로그인할 수 있습니다.** 담당자는 임계값
변경 · 문서 삭제 · 지침 교체 권한을 가지니, 시연이 끝나면 인스턴스를 내리거나
`DEMO_PASSWORD` 를 바꿔 재시드하세요.

로그인은 프론트 `/login` 입니다. 회원가입(`/signup`)으로 새 계정을 만들 수도 있지만,
그 계정은 어느 프로젝트에도 속하지 않으므로 담당자에게 초대 코드를 받아 참여해야
데모 데이터가 보입니다. 초대 코드는 시드 로그의 `invite_code=...` 에 찍히고,
Mike 로 로그인해 **멤버** 화면에서도 확인할 수 있습니다.

💡 시연은 **두 브라우저 프로필**(또는 일반 창 + 시크릿 창)로 지수와 Mike 를 동시에
띄워 두면 편합니다. 질문 → 확인 카드 도착 → 30초 판단이 한 화면 전환으로 이어집니다.

#### 이미 다른 비밀번호로 시드한 서버라면

⚠️ **`.env` 만 고쳐서는 바뀌지 않습니다.** `DEMO_PASSWORD` 는 **시드가 도는 순간에만**
읽혀 해시로 `users.password_hash` 에 박힙니다. 이후로는 로그인이 DB 의 해시만 보므로,
env 를 고치고 컨테이너를 다시 띄워도 예전 비밀번호가 그대로 통합니다.

먼저 `.env` 를 맞추고 `api` 를 새 env 로 다시 만듭니다. `docker compose exec` 는
**컨테이너가 만들어질 때의 env** 를 물려주므로, 이 단계를 건너뛰면 시드가 예전 값을
다시 해시합니다.

```bash
sed -i 's/^DEMO_PASSWORD=.*/DEMO_PASSWORD=demo1234!/' .env
```

```bash
docker compose up -d api
```

여기서 갈립니다. **`--with-history` 로 채운 이력이 있느냐**가 기준입니다.

**이력이 없거나, 다시 채워도 되면 — 재시드**

`--reset` 은 데모 프로젝트와 그 하위 데이터를 지우고 다시 넣습니다. 유저는 지우지 않고
같은 이메일에 새 해시를 덮어씁니다.

```bash
docker compose exec api python scripts/seed.py --reset
```

**이력을 지켜야 하면 — 비밀번호만 교체**

25~30분·$1.3 짜리 이력을 날리지 않고 세 계정의 해시만 갈아끼웁니다. 프로젝트·질문·
지표는 그대로입니다.

```bash
docker compose exec api python -c "
import asyncio
from sqlalchemy import update
from app.core.security import hash_password
from app.database import AsyncSessionLocal
from app.models.user import User

EMAILS = ['mike@devcorp.example', 'jisoo@globalmart.example', 'minjun@globalmart.example']

async def main():
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            update(User).where(User.email.in_(EMAILS)).values(password_hash=hash_password('demo1234!'))
        )
        await db.commit()
        print(f'{result.rowcount}명 교체됨')

asyncio.run(main())
"
```

`3명 교체됨` 이 아니면 시드가 아직 안 돌았거나 이메일이 다른 것입니다 — 그때는 위의
재시드 경로로 가세요. 확인은 로그인으로 합니다.

```bash
curl -s -X POST localhost:8000/api/v1/auth/login -H 'Content-Type: application/json' -d '{"email":"jisoo@globalmart.example","password":"demo1234!"}' -o /dev/null -w '%{http_code}\n'
```

### 데모가 둘입니다 — 불침번 자체 데모

기본 데모(`GlobalMart JP Launch`) 옆에 **불침번 자신을 지식으로 삼는 프로젝트**를 하나 더
띄울 수 있습니다. 지식이 이 저장소의 실제 문서라서, 심사위원이 방금 본 시스템에 대해
그대로 물어볼 수 있습니다.

| | 기본 (`globalmart`) | 불침번 (`bulchimbeon`) |
|---|---|---|
| 프로젝트 | GlobalMart JP Launch | Bulchimbeon Platform |
| 지식 | 가상 커머스 API 문서 4개 (영어) | 불침번 문서 5개 — **프론트 영어 · 백엔드 한국어** |
| 담당자 | Mike Chen | Alex Rivera (`alex@bulchimbeon.example`) |
| 질문자 | 지수 · 민준 | 같은 계정 |
| 임계값 | M-1 실측값 | 같은 값에서 시작 (필요하면 이 프로젝트만 조정) |

두 프로젝트는 서로를 밀어내지 않습니다. `projects.settings` 도 일일 LLM 호출 상한 집계도
**프로젝트별**이라, 한쪽을 조정하거나 이력을 채워도 다른 쪽은 그대로입니다. 로그인하면
프로젝트 목록에 둘 다 보입니다.

**혼합 언어가 핵심입니다.** 파이프라인은 한국어 질문을 영어로 번역해 검색하므로, 영어
문서는 축이 같고 한국어 문서는 교차언어 매칭이 됩니다. 그래서 "액세스 토큰은 몇 분
유효한가요"가 🔴 **충돌**로 떨어집니다 — 영어 프론트 가이드는 30분, 한국어 운영 규칙은
60분이라고 적혀 있고, 문서가 두 언어로 나뉜 팀에서 실제로 생기는 어긋남입니다.

#### 세팅 순서

이 데모는 백엔드 브랜치에 있습니다. 아직 `main` 에 병합하지 않았으므로 브랜치를 지정해
배포합니다 (이미지를 다시 굽습니다).

```bash
sh scripts/deploy.sh --backend claude/demo-bulchimbeon-profile
```

① 프로젝트·문서만 먼저 넣습니다. 인제스트 임베딩만 쓰므로 몇 센트, 1분 안쪽입니다.

```bash
docker compose exec api python scripts/seed.py --reset --profile bulchimbeon
```

② **이력을 돌리기 전에 검색 점수를 잽니다.** 교차언어 유사도가 `similarity_floor`(0.444)
아래로 내려가면 한국어 근거 질문이 전부 강제 🔴 `no_evidence` 가 되는데, 그걸 30분·$1.2
짜리 이력을 다 돌린 뒤에 알게 되면 그 시간을 잃습니다. 이 측정은 질문당 호출 2회라
전부 합쳐도 몇 센트입니다.

```bash
docker compose exec api python scripts/probe_seed_docs.py --profile bulchimbeon --answerer alex@bulchimbeon.example
```

Q1~Q6(영어 근거)은 높게, Q7~Q12(한국어 근거)는 그보다 낮게 나오는 것이 정상입니다.
**판정 기준은 `sim_raw` 가 0.444 를 넘느냐** 하나입니다. 넘으면 ③으로 가고, 한국어 계열이
그 아래로 내려가면 `scripts/demo_profiles.py` 의 `BULCHIMBEON.settings_overrides` 에
`{"similarity_floor": <낮춘 값>}` 을 넣고 ①부터 다시 합니다 — **이 프로젝트에만** 적용되고
기본 데모의 실측값은 건드리지 않습니다.

③ 이력·지표를 채웁니다. 질문 109건 ≈ 327 호출, 25~30분, 약 $1.2 입니다.
**발표 당일 말고 전날 돌리세요.**

```bash
docker compose exec api python scripts/seed.py --reset --with-history --profile bulchimbeon
```

④ **그 결과를 픽스처로 내보내 git 에 올립니다.** 이 단계가 ③을 한 번으로 끝냅니다.

```bash
docker compose exec api python scripts/history_fixture.py --profile bulchimbeon
```

컨테이너 안에 만들어진 파일을 꺼내 커밋합니다.

```bash
docker compose cp api:/app/seed/bulchimbeon/history.json bulchimbeon-backend/bulchimbeon-api/seed/bulchimbeon/history.json
```

이후로는 누가 어디서 시드하든 **0원 · 수 초 · 완전히 같은 데모**가 뜹니다.

```bash
docker compose exec api python scripts/seed.py --reset --profile bulchimbeon --from-fixture
```

#### 왜 이력을 손으로 짓지 않나요

매칭률·등급·정확도는 발표에서 **우리 파이프라인의 실측**으로 읽힙니다. 손으로 적으면 그
화면이 근거를 잃습니다. 코퍼스가 성립하는지 보려면 어차피 한 번은 진짜로 돌려야 하므로,
그 결과를 버리지 않고 고정하는 것뿐입니다. 덤으로 발표 당일의 30분 창·일일 호출 상한·
API 장애가 변수에서 사라집니다.

픽스처가 옮기지 않는 것이 셋 있습니다. `llm_usage` 는 오늘자 사용량으로 잡혀 **라이브
질문이 상한에 걸리므로** 제외하고, 공식 Q&A 임베딩은 임포트 때 **지금 모델로 다시**
만들며(모델이 바뀌면 재사용이 조용히 안 걸립니다), 시각은 상대값으로 적어 임포트가 지금
기준으로 되돌립니다 — 지표가 `now() - 30일` 창으로 읽기 때문에 절대 시각을 심으면 한 달
뒤에 화면이 빕니다.

#### 발표장에서 던질 질문

| 질문 | 기대 | 보여 주는 것 |
|---|---|---|
| VITE_API_BASE_URL 을 바꾸면 컨테이너만 다시 시작해도 반영되나요? | 🟢 즉답 | 근거 인용과 매칭률 |
| 액세스 토큰은 몇 분 동안 유효한가요? | 🔴 충돌 | 영어·한국어 문서가 어긋난 것을 잡아 담당자에게 넘김 |
| 모바일 앱은 언제 출시되나요? | 🔴 근거 없음 | 지어내지 않고 보류 |

이 셋의 **원문은 이력에서 빼 두었습니다.** 이력이 미리 던지면 발표 당일에는 이미 처리된
질문이 되거나 재사용 경로로 빠져 매칭률·인용이 사라집니다.

### 앞단은 Cloudflare Tunnel 입니다

cloudflared 는 **다른 LXC 에서 LAN 을 건너옵니다.** 그래서 `api` 와 `web` 의 포트를
루프백(`127.0.0.1:`)에 묶으면 안 됩니다 — 터널이 못 붙어 Cloudflare 가 502 를 뱉는데,
서버 로그에는 아무것도 안 남아 진단이 오래 걸립니다.
이 서버에 공인 IP 가 없어서 터널을 쓰는 것이므로, 열려도 LAN 까지입니다.
터널이 한 도메인을 받아 `/api/*` 는 `api:8000` 으로, 나머지는 `web:8080` 으로 보냅니다.
브라우저 입장에서는 프론트와 API 가 같은 오리진이라 CORS 를 타지 않습니다.

cloudflared 쪽 ingress 는 이렇게 생겼습니다. ⚠️ **`/api/` 규칙이 catch-all 보다 위**에
있어야 하고, 주소는 `localhost` 가 아니라 도커 호스트의 **LAN IP** 입니다 — cloudflared 가
다른 LXC 에서 건너오기 때문입니다.

```yaml
ingress:
  - hostname: 공개도메인
    path: ^/api/
    service: http://<도커호스트 LAN IP>:8000
  - hostname: 공개도메인
    service: http://<도커호스트 LAN IP>:8080
  - service: http_status:404
```

대시보드(Zero Trust → Networks → Tunnels → Public Hostnames)로 관리한다면 같은 호스트명에
Path `^/api/` 항목을 하나 더 만들고 기존 항목보다 위로 올리면 같은 결과입니다.
이 규칙이 빠지면 **로그인이 조용히 실패합니다** — 아래 「막혔을 때」를 보세요.

프론트 nginx 에 `/api` 프록시 블록이 없는 것이 이 구성의 전제입니다.
한 번 더 프록시하면 홉만 늘고 버퍼링·타임아웃 설정이 두 군데로 갈리는데,
**SSE 는 버퍼링 하나만 어긋나도 조용히 멈춥니다.**

구성을 바꾸려면 `.env` 의 `VITE_API_BASE_URL` · `CORS_ORIGINS` · `API_BASE_URL`
세 값을 **함께** 옮겨야 합니다. 하나만 고치면 기동은 되고 요청만 막혀서 진단이 오래 걸립니다.
`VITE_API_BASE_URL` 은 빌드 시각에 번들로 박히므로 고쳤다면 `--build` 로 다시 말아야 합니다.

### 서브모듈 핀은 "조합"입니다

이 저장소의 커밋 하나가 **"프론트 A + 백엔드 B"** 조합 하나를 기록합니다. 그래서 옵션 없이
`deploy.sh` 를 돌리면 커밋에 박힌 그 조합 그대로 뜨고, 롤백도 조합 단위로 됩니다.

⛔ `--backend` · `--frontend` 로 잠깐 옮긴 상태를 **커밋하지 마세요.** 기록이 깨져
어느 조합으로 돌아가야 하는지 알 수 없게 됩니다. 스크립트는 끝에서 포인터가 움직였는지
경고만 하고 `git add` 는 하지 않습니다. 되돌리려면
`git submodule update --init --recursive` 입니다.

> 예전에는 프론트 `main` 이 구현을 걷어낸 뼈대라 `Dockerfile` 이 없어서 배포할 때마다
> 다른 브랜치를 지정해야 했습니다. 프론트 PR #2(`woojin` 병합) 이후로는 `main` 에 구현과
> `Dockerfile` 이 다 들어와서, 옵션 없이 그냥 돌리면 됩니다.

### 막혔을 때

**로그인 화면에 "이메일 또는 비밀번호를 확인해 주세요" 만 계속 뜹니다**

⚠️ **이 문구는 비밀번호가 틀렸다는 뜻이 아닙니다.** 프론트 로그인 화면이 모든 예외를
`catch` 하나로 뭉개기 때문에 네트워크 실패·404·405·500 도 전부 같은 문장으로 나옵니다.
그래서 **요청이 API 까지 갔는지부터** 갈라야 합니다. 세 갈래이고 원인이 전부 다릅니다.

① 서버 안에서 API 를 직접 두드립니다 — 터널·프론트를 건너뜁니다.

```bash
curl -s -o /dev/null -w '%{http_code}\n' localhost:8000/api/v1/auth/login -X POST -H 'Content-Type: application/json' -d '{"email":"jisoo@globalmart.example","password":"demo1234!"}'
```

`401` 이면 계정 문제입니다 — 아래 ②. `200` 인데 브라우저에서만 실패하면 경로 문제 ③.

② 계정이 있는지, 해시가 `demo1234!` 인지 한 번에 봅니다.

```bash
docker compose exec api python -c "
import asyncio
from sqlalchemy import select
from app.core.security import verify_password
from app.database import AsyncSessionLocal
from app.models.user import User

async def main():
    async with AsyncSessionLocal() as db:
        rows = (await db.execute(select(User.email, User.password_hash))).all()
        print(f'유저 {len(rows)}명')
        for email, digest in rows:
            print(' ', email, '→ demo1234! 맞음' if verify_password('demo1234!', digest) else '→ demo1234! 아님')

asyncio.run(main())
"
```

`유저 0명` 이면 **시드가 안 돌았습니다** — `deploy.sh` 는 시드를 돌리지 않습니다.
「데모 계정으로 로그인」의 시드 명령을 실행하세요. `아님` 이면 예전 `DEMO_PASSWORD` 로
해시된 것이니 같은 절의 해시 교체 명령을 쓰세요.

③ 브라우저가 받는 것을 봅니다. **`content-type` 이 판별점입니다.**

```bash
curl -si https://공개도메인/api/health | head -5
```

- `application/json` → 정상. 여기까지 왔다면 ②로 돌아가세요.
- `text/html` 200 → 터널이 `/api/*` 를 프론트 nginx 로 보내고 있습니다. nginx 가 SPA
  폴백으로 `index.html` 을 200 으로 돌려주는 것이고, POST 는 `405 Not Allowed` 가 됩니다.
  **로그인 요청이 FastAPI 에 도달조차 못 합니다.** 터널 ingress 에 `/api/` 규칙이
  빠졌거나 catch-all 아래에 있는 것입니다 — 앞 절의 ingress 예시를 보세요.

⛔ 이걸 프론트 nginx 에 `/api` 프록시 블록을 넣어 우회하지 마세요. 홉이 늘고 버퍼링·
타임아웃 설정이 두 군데로 갈리는데, **SSE 는 버퍼링 하나만 어긋나도 조용히 멈춥니다.**

**`password authentication failed for user "bulchimbeon"`**

`POSTGRES_PASSWORD` 는 `pgdata` 볼륨이 **처음 만들어질 때만** 적용됩니다.
볼륨이 이미 있으면 Postgres 가 `Skipping initialization` 하고 넘어가므로
`.env` 를 새로 만들어도 DB 안의 비밀번호는 예전 것이 그대로 남습니다.

```bash
docker compose down -v   # ⚠️ pgdata·storage 를 모두 지웁니다
```

운영 데이터가 쌓인 뒤라면 볼륨을 지우지 말고 `.env` 의 `POSTGRES_PASSWORD` 를
예전 값으로 되돌리세요.

**빌드 중 CPU·메모리가 100% 에서 멈춥니다**

`vite build` 구간이 피크입니다. `deploy.sh` 는 이미 이미지를 하나씩 빌드하지만,
그래도 부족하면 스왑을 조금 붙이거나 메모리를 늘리는 편이 빠릅니다.
스왑이 0 이면 커널이 OOM 킬 대신 페이지 회수로 겉돌아 **죽지도 않고 멈춘 것처럼** 보입니다.

**`api` 가 계속 `health: starting` 이고 로그에 `GET /api/health ... 404`**

`api` **이미지**가 낡은 백엔드 소스로 구워진 것입니다. 헬스 경로는 예전에 `/health`
였다가 `/api/health` 로 옮겨졌으므로, 이미지가 그 이전 소스면 헬스체크가 영원히
404 를 받습니다. 앱 자체는 멀쩡히 떠 있어서 원인이 잘 안 보입니다.

```bash
curl -s -o /dev/null -w '%{http_code}\n' localhost:8000/health   # 200 이면 낡은 이미지다
```

⛔ **`docker compose up -d` 는 이미지가 이미 있으면 다시 빌드하지 않습니다.**
`git pull` 로 소스를 최신화해도 이미지는 예전 것이 그대로 쓰입니다. 소스를 바꿨으면
반드시 다시 구워야 합니다 — `deploy.sh` 가 그 일을 합니다.

```bash
sh scripts/deploy.sh
```

⚠️ **마이그레이션이 다 올라간 것은 최신이라는 증거가 아닙니다.** 스키마와 라우팅은
서로 다른 시점에 바뀌었습니다 — `0012` 를 추가한 커밋이 헬스 경로를 옮긴 커밋보다
오래됐기 때문에, `migrate` 가 `0012` 까지 성공해도 라우팅은 옛 형태일 수 있습니다.

체크아웃이 최신인지는 따로 봅니다. 이쪽이 낡았다면 `git submodule update --init --recursive`.

```bash
git -C bulchimbeon-backend log --oneline -1
```

**`migrate` 가 실패하면 `api` 는 시작하지 않습니다**

의도된 동작입니다(`service_completed_successfully`). 마이그레이션 실패가 앱
재시작 루프에 묻히면 원인이 안 보이기 때문에, 거기서 멈추고 로그를 남깁니다.

```bash
docker compose logs migrate
```

### 백업은 두 가지를 함께 받습니다

- `pgdata` 볼륨 — 질문·답변·청크·임베딩
- `storage` 볼륨 — 업로드 **원본 파일**

DB 만 백업하면 청크는 남지만 원문은 복구되지 않고, 문서 재인제스트도 불가능해집니다.

### 서브모듈 최신화

각 서비스 저장소에 새 커밋이 올라왔을 때, 이곳의 포인터를 옮겨주면 됩니다.

```bash
git submodule update --remote
git add bulchimbeon-backend bulchimbeon-frontend
git commit -m "chore: 서브모듈 최신화"
```

서브모듈은 **특정 커밋을 가리키는 포인터**입니다.
따라서 이 저장소의 커밋 하나가 "프론트 A 버전 + 백엔드 B 버전" 조합을 그대로 기록합니다.
배포 후 문제가 생기면 이 저장소의 커밋만 되돌려도 양쪽이 함께 이전 상태로 돌아갑니다.

## 더 읽을 거리

- 기획·설계 문서 — `bulchimbeon-backend/bulchimbeon-api/docs/`
- API 계약서 — `bulchimbeon-backend/bulchimbeon-api/docs/05-api-contract.md`
- 화면 디자인 — [Figma](https://www.figma.com/design/zYXzpJCkdmZJrdhsO4fuse/?node-id=128-2)
