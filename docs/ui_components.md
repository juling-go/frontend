# UI 컴포넌트 명세

이어서 무엇을 시도할지는 [design_roadmap.md](./design_roadmap.md)에, 무엇을 언제 할지는 [implementation-tasks.md](./implementation-tasks.md)에 정리했다.

## 화면 (Screens)

| 이름 | 파일 | 설명 |
|---|---|---|
| LoginScreen | `lib/screens/login_screen.dart` | 소셜 로그인 |
| HomeScreen | `lib/screens/home_screen.dart` | 탭 진입점, 커리큘럼 로딩 + BottomNav |
| CurriculumScreen | `lib/screens/curriculum_screen.dart` | 커리큘럼 목록/상세 |
| ContentScreen | `lib/screens/content_screen.dart` | 학습 컨텐츠 브라우저 |
| LevelAssessmentScreen | `lib/screens/level_assessment_screen.dart` | 수준 평가 (미구현) |
| ProfileScreen | `lib/screens/profile_screen.dart` | 유저 정보 및 통계 |
| SectionScreen | `lib/screens/section_screen.dart` | 섹션(노드)의 스테이지 목록 |
| StageScreen | `lib/screens/stage_screen.dart` | 문제 풀이 + 채점 |
| SettingsScreen | `lib/screens/settings_screen.dart` | 디자인 전환, 계정 정보, 로그아웃, 회원탈퇴 |

---

## 화면별 컴포넌트

### HomeScreen
```
HomeScreen
├── BottomNavigationBar          하단 탭 바
├── CurriculumSectionHeader      진행 중 커리큘럼 헤더 카드
│   └── SectionInfoInnerCard     노드 상세 정보 (중첩 카드)
├── SectionInfoCard              폴백 섹션 헤더 카드
├── StageCard                    스테이지 목록 아이템
│   └── CoinWidget               스테이지 상태 동전 (완료/현재/잠금)
└── StagePopup                   스테이지 시작 팝업 (Dialog)
```

### CurriculumScreen
```
CurriculumScreen
├── CurriculumHeader             "커리큘럼" 타이틀 헤더
├── CurriculumCard               커리큘럼 목록 아이템
│   └── ActiveBadge              "진행 중" 배지
└── CurriculumDetailView         상세 뷰
    ├── DetailHeader             뒤로가기 + 제목 + 액션 버튼
    │   ├── StartButton          시작하기 (raised3DButton, 파랑)
    │   └── ContinueButton       이어하기 (raised3DButton, 초록)
    ├── NodeWidget               학습 노드 구체
    ├── EdgePainter              노드 연결선 (CustomPainter)
    └── LegendItem               완료/학습가능/잠금 범례
```

### ContentScreen
```
ContentScreen
├── ContentHeader                "컨텐츠" 타이틀 헤더
├── SubjectTabs                  과목 가로 탭
├── ChapterCard                  챕터 목록 아이템
│   └── ChapterIndexBadge        챕터 번호 배지
└── ChapterPopup                 챕터 상세 팝업 (Dialog)
    └── SectionCard              섹션 아코디언 카드
```

### ProfileScreen
```
ProfileScreen
├── ProfileAvatar                프로필 원형 아바타
├── UserInfoCard                 학습 등급 + 목표 카드
│   └── GoalBadge                학습 목표 배지 ("고수 투자자")
└── StatsCard                    학습 통계 카드 (고정 높이 없음)
    └── StatColumn               섹션 수 / 스테이지 수
        ├── (neo)  원형 배지 안에 숫자
        └── (flat) 큰 숫자 그대로
```

### StageScreen
```
StageScreen
├── ProgressBar                  문제 진행 바 (AppBar bottom)
├── TypeBadge                    문제 유형 배지 (O/X, 단일, 복수)
├── QuestionText                 문제 본문
├── OxChoices                    O / X 선택 버튼 쌍
├── OptionList                   객관식 선택지 목록
│   └── OptionItem               선택지 아이템
├── HintBox                      힌트 박스 (amber 색상)
├── ResultMessage                정답/오답 결과 메시지
├── BottomBar                    하단 바
│   ├── HintButton               힌트 토글 버튼
│   └── SubmitButton             확인 / 다음 / 완료 버튼
├── FlashOverlay                 정답/오답 전체화면 플래시
└── ConfettiAnimation            정답 시 콘페티 (CustomPainter)
```

### LoginScreen
```
LoginScreen
├── AppLogo                      앱 아이콘 원형
├── AppTitle                     "투자 학습앱 주링고"
└── SocialLoginButtons           스킨에 따라 모양이 갈림
    ├── (neo)  CircleSocialButton  원형 브랜드 마크 (IconButton)
    └── (flat) WideSocialButton    전체 너비 버튼 + 로고 + 문구
```

---

## 공유 요소

파일: `lib/theme/app_theme.dart`

| 이름 | 설명 |
|---|---|
| `buildAppTheme(AppSkin)` | 스킨에 맞는 `ThemeData` 생성. `AppPalette`를 `ThemeExtension`으로 싣는다 |
| `card3D(context, {radius, border})` | 카드 데코레이션. neo=그라디언트+듀얼 그림자, flat=단색+1px 테두리 |
| `headerDecoration(context)` | 화면 상단 헤더 데코레이션 |
| `raised3DButton(context: ..., ...)` | 주요 버튼. neo=입체(아래 3px 턱), flat=평면. 두 스킨 모두 `InkWell` + 버튼 시맨틱 |

세 헬퍼 모두 `BuildContext`를 받는다 — 현재 스킨을 테마에서 읽어야 하기 때문이다.

---

## 디자인 스킨 (Skins)

앱은 두 가지 디자인을 담고 있고 설정 화면에서 즉시 전환한다. 색뿐 아니라
카드·버튼의 **형태**까지 달라지므로, 색은 `AppPalette`가, 형태는 위 데코레이션
헬퍼가 분기한다.

| 스킨 | 설명 |
|---|---|
| `AppSkin.neo` | 입체 다크. 그라데이션 카드와 입체 버튼 (기본값) |
| `AppSkin.flat` | 플랫 라이트. 평면 표면과 높은 대비 |

파일: `lib/theme/app_palette.dart`

- `AppPalette`는 `ThemeExtension`이다. **새 코드는 `context.p.surface` 로 읽는다.**
- `AppColors.surface` 는 같은 팔레트를 정적으로 중계하는 **호환 계층**이다.
  `CustomPainter`처럼 `BuildContext`가 없는 자리를 위해 남겨 두었고,
  그런 곳부터 점진적으로 `context.p` 로 걷어내면 된다.
- `*900`은 옅은 컨테이너 배경, `*300`은 그 위에 올리는 글자다. flat에서는 두
  값의 밝기가 뒤집혀 대비가 유지된다 (`blue900`+`blue300` = 7.6:1).
- 색이 들어간 텍스트 스타일(`AppTextStyles.dimmedLabel` 등)은 스킨에 따라
  달라지므로 `const`가 아니라 `context`를 받는 함수다.

---

## 상태 (State)

파일: `lib/state/`

| 이름 | 파일 | 설명 |
|---|---|---|
| `AppScope` | `app_scope.dart` | 저장소를 위젯 트리에 노출하는 InheritedWidget |
| `AuthRepository` | `auth_repository.dart` | 로그인 상태 (ChangeNotifier, SharedPreferences 영속) |
| `ProgressRepository` | `progress_repository.dart` | 커리큘럼별 학습 진행률 (ChangeNotifier, SharedPreferences 영속) |
| `SkinController` | `skin_controller.dart` | 선택한 디자인 (ChangeNotifier, SharedPreferences 영속) |

화면에서 사용하는 방법:

```dart
final progress = AppScope.of(context).progress;
return ListenableBuilder(
  listenable: progress,
  builder: (context, _) => Text('${progress.totalCompletedStages}'),
);
```

### 스테이지 완료 판정

`StageScreen`은 문항별 정답 여부를 모아 `StageResult`를 반환합니다.
`SectionScreen`은 `StageResult.passed`(정답률 `kStagePassRatio` = 60% 이상)일 때만
`ProgressRepository.markStageCompleted()`를 호출합니다.
