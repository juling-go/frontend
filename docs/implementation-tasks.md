# 구현 과제

> 상태: 초안 · 마지막 확인: 2026-09-11 (frontend `9665c2d`)

프론트엔드 레포 안에서 끝나는 **구현 과제의 목록**이다. 과제마다
무엇을 만드는가 · 무엇에 막혀 있는가 · 끝났다고 어떻게 확인하는가만 적는다.

왜 그렇게 고치는지, 어떤 선택지가 있는지는 [design_roadmap.md](./design_roadmap.md)에 있다.
이 문서는 그 판단을 **작업 단위로 세어 놓은 자리**일 뿐이라 근거를 다시 적지 않는다.

## 이 문서가 갖는 것 · 갖지 않는 것

| 갖는 것 | 갖지 않는 것 | 그것의 자리 |
|---|---|---|
| 과제 단위와 과제 사이의 순서 | 설계 근거 · 선택지 | [design_roadmap.md](./design_roadmap.md) |
| 선행 조건 — 무엇이 이 과제를 막고 있는가 | 미결정 그 자체 | 상위 `docs/open-questions.md` |
| 완료를 무엇으로 확인하는가 | 통과 · 해금 · 등급 규칙 | 상위 `docs/requirements/` |
| 산출물이 놓일 경로 | 화면별 컴포넌트 구조 | [ui_components.md](./ui_components.md) |
| | 지금 무엇이 없는가 | 상위 `docs/architecture/system-map.md` |
| | 레포 간 순서 · 마일스톤 | 상위 `docs/roadmap/milestones.md` |
| | 검증 명령과 마지막 실행 결과 | 상위 `docs/engineering/verification.md` |

상위 저장소 문서는 링크 대신 경로로 적었다. 이 레포를 단독으로 클론하면
`../../docs/`가 없어 링크가 깨지기 때문이다.

## 읽는 법

과제를 **무엇이 막고 있는가**로 묶었다. 이 프로젝트에서 프론트엔드 작업이 멈추는 이유는
대부분 난이도가 아니라 선행 결정이라, 난이도순·화면순으로 묶으면 지금 집을 수 있는 것이
무엇인지 보이지 않는다.

| 묶음 | 뜻 |
|---|---|
| **A** | 막는 것이 없다. 오늘 시작할 수 있다 |
| **B** | 서버 계약이 정해져야 끝낼 수 있다 (상위 `docs/roadmap/milestones.md` M1) |
| **C** | 미결 질문이 풀려야 시작할 수 있다 |

---

## 묶음 A — 막는 것이 없다

| # | 과제 | 산출물 | 완료 확인 | 근거 |
|---|---|---|---|---|
| F1 | 로딩 · 오류 · 빈 상태 화면 3종 | `lib/widgets/state_views.dart` | 목 서비스가 실패하도록 바꿔도 화면에 복구 경로(`다시 시도`)가 남는다 | [design_roadmap](./design_roadmap.md) 2-3 |
| F2 | 화면 파일에서 위젯 추출 | `lib/widgets/` (`StageCard` · `CoinWidget` · `OptionItem` · `TypeBadge` · `HintBox` · `ResultBanner` · `NodeWidget`) | 화면 파일이 화면 조립만 하고, 페인터·카드·다이얼로그가 밖에 있다 | 3-1 |
| F3 | `AppColors` 정적 접근 걷어내기 | `lib/theme/app_colors.dart` 삭제 | `grep -rn 'AppColors\.' lib`가 0건 | 3-2 |
| F4 | 남은 `GestureDetector` 8곳을 `InkWell`로 | 화면 4개 | 스크린리더가 탭 대상을 버튼으로 읽고, 선택지가 라디오 그룹으로 읽힌다 | 2-1 |
| F5 | 한글 폰트 번들 | `assets/fonts/`, `pubspec.yaml`의 `fonts:` | iOS·Android에서 같은 화면의 자간·굵기가 같다 | 2-2 |
| F6 | `AppSpacing`을 5단계 스케일로 수렴 | `lib/theme/app_spacing.dart` | 새 화면에서 고를 값이 `xs/sm/md/lg/xl` 안에 있다 | 2-4 |
| F7 | 글자 크기 확대 대응 | 화면 전반 | 시스템 글자 크기 최대에서 전 화면에 잘림이 없다 | 3-4 |
| F8 | 모션 줄이기 경로 | 애니메이션을 쓰는 화면 | 시스템 "동작 줄이기"를 켜면 컨페티·플래시·흔들림이 나오지 않는다 | [design_roadmap](./design_roadmap.md) 5 |
| F9 | 테스트 공백 메우기 | `test/` | 문항 풀이 흐름(L5)과 스테이지 해금(L2)이 자동 테스트로 지켜진다 | 아래 |
| F10 | 죽은 필드 `Stage.isCompleted` 정리 | `lib/models/stage.dart` | 진행률의 출처가 `ProgressRepository` 하나다 | 아래 |

### F3과 F2는 같은 파일을 건드린다

`AppColors`를 막고 있는 것은 `BuildContext`가 없는 페인터 두 곳이고
([design_roadmap](./design_roadmap.md) 3-2), 그 페인터는 F2가 옮기려는 화면 파일 안에 있다.
따로 돌리면 같은 파일을 두 번 크게 고치게 된다. **파일 단위로 두 과제를 함께 처리하는 편이 낫다** —
페인터를 `lib/widgets/`로 옮기면서 팔레트를 생성자로 주입하고, 그 파일의 `AppColors`를 같이 걷는다.

### F8 — 모션은 취향이 아니라 접근성이다

전정기관이 예민한 사용자에게 전체화면 플래시는 실질적인 장벽이다
([design_roadmap](./design_roadmap.md) 5). 지금 앱에는 **모션을 줄이는 경로가 없다** —
`MediaQuery.disableAnimationsOf(context)`를 보는 곳이 한 군데도 없다.

```bash
grep -rn 'disableAnimations' lib
```

끄는 대상은 `stage_screen.dart`의 컨페티 · 결과 플래시 · 흔들림이 먼저다.
전환 애니메이션(`app_transitions.dart`)까지 묶을지는 실제로 켜 보고 정한다.

### F9 — 무엇이 비어 있는가

지금 테스트가 무엇을 지키고 무엇을 지키지 않는지는 상위 `docs/engineering/verification.md`가 갖는다.
그 목록에서 **프론트엔드가 스스로 메울 수 있는 것**이 이 과제다 — 문항 풀이 흐름과 화면 렌더는
서버 없이도 목으로 테스트할 수 있다. 여기가 아니라 F21이다
(유지 여부가 정해지기 전에는 만들 대상이 없다).

### F10 — 진행률의 출처가 둘이 될 자리

`Stage`에 `isCompleted` 필드가 선언되어 있지만 **읽는 곳이 없다.** 화면은 완료 여부를
`ProgressRepository`에서 가져온다(`section_screen.dart`의 완료 집합, `curriculum_screen.dart`의 노드 판정).

지금은 그냥 죽은 필드지만, 서버가 `isCompleted`를 함께 내려보내기 시작하면
**같은 사실에 출처가 둘**이 된다. 둘이 어긋날 때 화면이 무엇을 믿는지가 정해져 있지 않다.
진행률을 누가 갖는지는 아직 미결이므로(상위 `docs/open-questions.md` Q2),
결론이 나기 전에 **필드를 지워 두는 쪽**이 안전하다. 그때 F17에서 제대로 들인다.

---

## 묶음 B — 서버 계약이 정해져야 한다

상위 `docs/contracts/api-rest.md`의 "정해야 하는 것" 표가 비어야 이 묶음이 끝난다.
표가 비기 전에도 **F11과 F12의 골격은 만들 수 있다** — 경로와 필드만 나중에 채운다.

| # | 과제 | 산출물 | 막는 것 | 완료 확인 |
|---|---|---|---|---|
| F11 | 모델 역직렬화 | `lib/models/` | S2 · S3 응답 모양 | `Curriculum` · `Stage` · `Question`을 JSON에서 만들 수 있다 |
| F12 | HTTP 클라이언트와 봉투 파싱 | `lib/services/` (+ `pubspec.yaml` 의존성) | api-rest 질문 1 · 2 · 3 | 성공 봉투와 오류 봉투가 모두 타입으로 다뤄지고, 오류가 F1의 화면으로 이어진다 |
| F13 | `ApiContentService` · `ApiCurriculumService` | `lib/services/` | S1 · S2 | 주입만 바꾸면 앱이 서버 데이터로 돈다 |
| F14 | 문항 어댑터 (`problem_info` → `Question`) | `lib/models/` 또는 `lib/services/` | S3, Q10 | 데이터 레포의 문항 JSON이 화면에 그려진다 |
| F15 | 실제 OAuth 로그인 | `lib/state/auth_repository.dart`의 `login()` 내부 | Q1 | 실제 계정으로 로그인하고, 앱을 껐다 켜도 유지된다 |
| F16 | 회원탈퇴를 서버에 반영 | `lib/screens/settings_screen.dart` | S7 | 탈퇴가 로그아웃과 다른 일을 한다 |
| F17 | 진행률 서버 동기화 | 새 경계 | Q2 | Q2의 결론대로 동작한다 |
| F18 | 목 제거 | `lib/mock/` 삭제 | F13 · F14 | 목 없이 앱이 끝까지 돈다 |

### F11이 이음매 표보다 먼저다

역직렬화가 없다는 **부재 자체는 상위 `docs/architecture/system-map.md`가 갖는다.**
여기서는 그것이 과제 순서에 무엇을 뜻하는지만 적는다.

이음매가 셋이라고 해서 작업도 셋이 아니다. `ContentService`(S1)는 모델에 `fromJson`이 있어
구현체만 쓰면 되지만, `CurriculumService`(S2)는 **역직렬화부터 만들어야 한다.**
커리큘럼 응답 하나에 노드 · 선수 관계 · 스테이지 · 문항이 전부 매달려 있어
F11에서 가장 큰 덩어리다.

어느 모델이 준비되어 있는지는 세어 보면 된다.

```bash
grep -rLn 'fromJson' lib/models/*.dart
```

여기에 `stage_result.dart`가 같이 나오지만 그것은 계산 결과라 지금은 필요 없다.
서버 채점으로 가면(Q10) 그때 대상이 된다.

### F14 — 매핑을 새로 정하지 않는다

`problem_info`의 문항 객체를 `Question`으로 바꾸는 **필드 대응표는 데이터 레포의 `README.md`가 갖는다**
(`프론트엔드 매핑` 절). 여기에 옮겨 적지 않는다 — 스키마가 바뀌면 이쪽만 낡는다.

정답(`answer`)을 서버가 내려보내는지는 채점 위치에 달려 있다(상위 `docs/open-questions.md` Q10).
**클라이언트 채점이 유지되면** 어댑터가 `correctIds`를 채우고 `StageResult`가 그대로 쓰인다.
**서버 채점으로 가면** `Question`에서 정답이 빠지고, `kStagePassRatio`는 화면이 표시용으로만 쓰는 값이 된다 —
기준의 권위가 서버로 넘어간다(상위 `docs/requirements/learning-loop.md` L1).

### F18 — 목을 지우는 순서

`lib/mock/`을 지우기 전에 **대체재가 동작하는 것을 먼저 확인한다**(상위 저장소 `CLAUDE.md`).
목 데이터는 테스트가 기대는 곳이기도 하므로, 지우는 PR은 F9가 만든 테스트가
실데이터·고정 픽스처 중 무엇을 쓸지 정한 뒤에 낸다.

---

## 묶음 C — 미결 질문이 풀려야 한다

결론이 나기 전에 시작하면 버린다. 질문의 내용과 선택지는 상위 `docs/open-questions.md`가 갖는다.

| # | 과제 | 막는 질문 | 결론에 따라 달라지는 것 |
|---|---|---|---|
| F19 | 위젯이 없는 문항 타입의 위젯 | Q3 | 만들 타입이 넷인지, 0개인지, 서버가 걸러 주는지 |
| F20 | 수준평가 화면 | Q6 | 화면 하나인지 온보딩 흐름 전체인지 |
| F21 | 스킨 결정의 후속 작업 | Q5 | 팔레트를 지울지, 스크린샷 테스트를 들일지, 라이트 입체감을 새로 만들지 |
| F22 | 반응형 레이아웃 | Q8 | 지원 타깃 폭 — 정해지기 전에는 최대 너비·2단 레이아웃을 정할 수 없다 |

### F19 — 지금 무엇을 못 그리는가

`QuestionType`에 없어 화면에 띄울 수 없는 타입의 **목록**은 상위 `docs/requirements/content-quality.md` C3가,
**타입별 문항 수**는 데이터 레포의 `README.md`와 검증 스크립트 출력이 갖는다.
여기에 숫자를 적지 않는다 — 문항이 늘면 바로 낡는다.

Q3의 결론이 "만든다"이면 위젯과 함께 `QuestionType` 확장, F14 어댑터의 분기,
그리고 타입별 채점 규칙이 한 묶음으로 따라온다. `StageResult`는 문항 단위 정오만 세므로
타입이 늘어도 그대로 쓸 수 있다.

---

## 여기에 넣지 않은 것

[design_roadmap.md](./design_roadmap.md)의 항목이 전부 과제가 된 것은 아니다.
아래는 **하지 말자는 뜻이 아니라, 아직 과제로 세울 만큼 정해지지 않았다는 뜻**이다.

| 항목 | 왜 뺐나 |
|---|---|
| 스테이지 로드맵 레일 (3-3) | 지금 화면도 동작한다. 고칠 결함이 아니라 해 볼 만한 변경이다 |
| 라이트 입체감 · 진행률 노출 · 완료 피드백 강약 (4-1 · 4-2 · 4-3) | 무엇을 만들지가 비교해 본 뒤에 정해진다. F21과 같은 자리 |
| flat 스킨 카드 분리감 (2-5) | 스킨을 유지할지(Q5) 정해지기 전에는 대상이 없다 |

디자인 방향이 정해져 과제가 되면 이 표에서 위로 옮긴다.

## 숫자가 필요하면

이 문서에는 세면 나오는 값을 적지 않았다. 필요할 때 아래를 돌린다
(모두 `frontend/`에서 실행하며, 2026-09-11에 실행해 [design_roadmap.md](./design_roadmap.md)의
값과 일치하는 것을 확인했다).

```bash
grep -rn 'AppColors\.' lib/screens | wc -l
```

```bash
grep -rn 'GestureDetector' lib/screens | wc -l
```

```bash
find lib -name '*.dart' | xargs wc -l | sort -rn | head
```

`lib`을 통째로 세면 `app_theme.dart`의 주석과 `app_colors.dart`의 정의가 섞여 값이 달라진다.
세려는 것은 **화면이 쓰는 곳**이므로 `lib/screens`로 좁힌다.

빌드·테스트 명령과 마지막 실행 결과는 상위 `docs/engineering/verification.md`가 갖는다.

## 과제가 끝나면

- 화면을 추가하거나 흐름을 바꿨으면 [ui_components.md](./ui_components.md)와
  상위 `docs/product/screen-flow.md`를 함께 고친다.
- [design_roadmap.md](./design_roadmap.md)에서 해결된 절은 **지운다.** 남겨 두면
  다음 사람에게 아직 유효한 제안으로 읽힌다.
- 이 문서에서 끝난 과제의 줄을 지운다. 과제 번호는 재사용하지 않는다.
- 미결 질문이 풀렸으면 결론을 소유 문서로 옮긴다 — 절차는 상위 `docs/README.md` 원칙 ⑤.
