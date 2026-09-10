# UI 컴포넌트 명세

## 화면 (Screens)

| 이름 | 파일 | 설명 |
|---|---|---|
| LoginScreen | `lib/screens/login_screen.dart` | 소셜 로그인 |
| HomeScreen | `lib/screens/home_screen.dart` | 탭 진입점, 홈 탭 + BottomNav 포함 |
| CurriculumScreen | `lib/screens/curriculum_screen.dart` | 커리큘럼 목록/상세 |
| ContentScreen | `lib/screens/content_screen.dart` | 학습 컨텐츠 브라우저 |
| LevelAssessmentScreen | `lib/screens/level_assessment_screen.dart` | 수준 평가 (미구현) |
| ProfileScreen | `lib/screens/profile_screen.dart` | 유저 정보 및 통계 |
| StageScreen | `lib/screens/stage_screen.dart` | 문제 풀이 화면 |

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
└── StatsCard                    학습 통계 카드
    ├── SectionStatCircle        학습 섹션 수 원형 표시
    └── StageStatCircle          학습 스테이지 수 원형 표시
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
└── SocialLoginButtons
    ├── KakaoButton              카카오 로그인 버튼
    └── GoogleButton             구글 로그인 버튼
```

---

## 공유 요소

파일: `lib/theme/app_decorations.dart`

| 이름 | 설명 |
|---|---|
| `card3D()` | 뉴모피즘 카드 데코레이션 (그라디언트 + 듀얼 그림자) |
| `headerDecoration()` | 화면 상단 헤더 데코레이션 |
| `raised3DButton()` | 이중 컨테이너 입체 버튼 위젯 |
