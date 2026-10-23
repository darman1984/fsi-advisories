---
type: 목차
---

# 금보원 보안권고 지식베이스

금융보안원 금융보안레그테크 카카오톡 채널로 받은 "사이버 위협정보 보안권고문" 알림을 팀이 같이 찾아볼 수 있게 정리한 문서예요. 2026-05-15부터 2026-10-23 오전까지 받은 알림 117건이 들어 있어요.

이 위키는 LLM 위키 방식으로 관리해요. 원본(`raw/`)은 그대로 두고, Claude가 [CLAUDE.md](../../CLAUDE.md)의 규칙대로 새 자료를 넣고(넣기), 질문에 답하고(묻기), 어긋난 곳을 찾아요(점검). 한 일은 [log.md](log.md)에 한 줄씩 쌓여요.

## 먼저 알아 둘 것

- **알림에는 제목만 있어요.** 카톡 알림은 "OOO 보안 업데이트 권고가 게시되었습니다"라는 한 줄과 안내 문구뿐이에요. 영향받는 버전, CVE, 조치 방법은 홈페이지 원문에서 확인해야 해요.
- **원문 보는 곳**: 금보원 홈페이지 `정보제공 › 사이버 위협정보 › 보안권고문`에서 같은 제목으로 찾아요.
- **알림 설정**: 홈페이지 `마이페이지 › 변경하기`에서 바꿔요. 업무 시간 외 수신 거부도 여기서 해요. 이 채널은 알림 수신을 허용한 이용자에게만 보내요.
- **분야와 종류는 kb에서 붙인 것이에요.** 알림 원문에는 없어요. 제품 성격과 제목 낱말로 나눴어서 금보원 분류와 다를 수 있어요.

## 목차

| 쪽 | 내용 | 이럴 때 봐요 |
| --- | --- | --- |
| [products.md](products.md) — 제품별 권고 | 제품 66개를 분야 7개로 나눠 건수, 날짜, 출처 줄을 적었어요. 자주 나온 제품 표가 맨 위에 있어요 | "우리가 쓰는 OOO에 권고가 있었나요?"에 답할 때 |
| [timeline.md](timeline.md) — 날짜순 전체 목록 | 117건을 월별로, 최근 것부터 원문 제목 그대로 | "지난주에 무슨 권고가 왔어요?", 놓친 알림을 찾을 때 |
| products/ — 제품 쪽 13개 | 권고가 3건 이상인 제품마다 한 쪽: [Cisco](products/cisco.md), [Linux Kernel](products/linux-kernel.md), [Citrix·NetScaler](products/citrix-netscaler.md), [Fortinet](products/fortinet.md), [Microsoft 정기 업데이트](products/microsoft-patch.md), [GitLab](products/gitlab.md), [WordPress](products/wordpress.md), [Adobe](products/adobe.md), [Apache](products/apache.md), [Ivanti](products/ivanti.md), [NGINX](products/nginx.md), [PHP](products/php.md), [Spring](products/spring.md) | 한 제품의 권고를 모아 보고, 원문에서 확인한 버전·조치를 적을 때 |
| [notices.md](notices.md) — 주의·안내 권고와 흐름 | 패치가 아닌 주의 11건과 안내 6건, 반복·몰림 같은 흐름, 알림만으로는 알 수 없는 것 | 패치 말고 따로 조치할 것이 있는지 볼 때 |
| [ontology.md](ontology.md) — 온톨로지 | 개념(알림, 권고문, 제품, 분야, 종류, CVE, 확인 사항)과 관계, 권고 ID, 제품 이름·분야·종류를 정하는 규칙 | 새 제목을 어느 제품·분야에 넣을지 정할 때. 쪽 속성의 뜻이 궁금할 때 |
| [log.md](log.md) — 바뀐 기록 | kb를 만들고 고친 날과 무엇을 바꿨는지 | kb가 언제까지의 알림을 담고 있는지 볼 때 |

## 나눈 기준

**종류** (제목 낱말로 나눴어요)

| 종류 | 기준 | 건수 |
| --- | --- | --- |
| 패치 | "보안 업데이트 권고", "패치 권고"처럼 업데이트를 적용하라는 권고 | 100 |
| 주의 | "주의 권고", "보안강화 권고", "보안 조치 권고" | 11 |
| 안내 | "정보공유", "안내", "수칙", "점검" | 6 |

**분야** (제품 성격으로 나눴어요, 한 제품은 대표 분야 하나에만 넣었어요)

| 분야 | 건수 | 예 |
| --- | --- | --- |
| 네트워크·보안장비 | 32 | Cisco, Fortinet, Citrix·NetScaler, Ivanti, Palo Alto, Check Point, WAF, NAC |
| 웹·서버·DB | 25 | NGINX, Apache, Spring, PHP, WordPress, OpenSSL, PostgreSQL, Oracle WebLogic, IBM |
| PC·업무용 SW | 20 | Adobe, 7-Zip, Zoom, OzWebLauncher, AnySign4PC, 나모 크로스에디터 |
| OS·가상화 | 15 | Linux Kernel, MS 정기 업데이트, Android, VMware, Linux KVM |
| 개발·운영 도구 | 10 | GitLab, Gitea, JetBrains, Portainer, Veeam, SolarWinds |
| AI·데이터 | 8 | NVIDIA, Langflow, MLflow, picklescan, Metabase |
| 위협 동향·점검 | 7 | CISA Exploit 정보, API 보안점검, 위성통신망 |

이름이 조금씩 다른 제목은 한 제품으로 묶었어요: "Linux kernel", "Linux Kernel", "Linux 제품"은 Linux Kernel로, "Citrix", "CitrixBleed", "NetScaler"는 Citrix·NetScaler로, "MS 6~9월 정기 보안 업데이트"는 Microsoft 정기 업데이트로, "Palo Alto PAN-OS GlobalProtect VPN"은 Palo Alto Networks로 묶었어요.

## 출처 표기

- 원본은 `raw/kakaotalk-2026-10-23.txt`예요. 카카오톡 "대화 내보내기"로 2026-10-23 11:40에 저장한 파일을 이름만 바꿔 복사했어요.
- 근거는 `:줄`로 달았어요. 원본 파일에서 그 알림의 `[금융보안레그테크]` 줄이에요(예: `:5`는 첫 알림).
- 원본은 고치지 않아요. kb와 원본이 다르면 원본이 맞아요.

## 새 알림 넣기

카톡에서 대화를 다시 내보내 `raw/kakaotalk-<저장한 날>.txt`로 넣고, Claude Code에 이렇게 부탁해요.

```text
raw/kakaotalk-<저장한 날>.txt를 위키에 넣어 줘. CLAUDE.md의 넣기 절차대로 관련 쪽을 모두 고치고 log.md에 "넣기"로 한 줄 적어 줘. 원본은 고치지 마.
```

홈페이지 원문을 읽었으면 내용을 붙여서 "이 원문을 위키에 넣어 줘"라고 해요. 영향 버전, CVE, 조치 방법이 제품 쪽의 "원문에서 확인한 것"에 들어가요. 절차는 [CLAUDE.md](../../CLAUDE.md)의 "넣기"에 있어요.
