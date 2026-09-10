import 'package:flutter/material.dart';

/// 앱이 지원하는 두 가지 디자인.
///
/// 두 스킨은 색뿐 아니라 **형태**도 다르다. [AppSkin.neo]는 그라데이션 카드와
/// 입체 버튼을 쓰고, [AppSkin.flat]은 평면 표면과 얇은 테두리를 쓴다. 형태
/// 분기는 `app_theme.dart`의 데코레이션 헬퍼가 담당한다.
enum AppSkin {
  /// 다크 전용 뉴모피즘. 팀이 구현한 기본 디자인.
  neo('입체 다크', '그라데이션 카드와 입체 버튼'),

  /// 라이트 플랫. 접근성 대비를 우선한 Material 3 스타일.
  flat('플랫 라이트', '평면 표면과 높은 대비');

  const AppSkin(this.label, this.description);

  final String label;
  final String description;
}

/// 스킨별 색 토큰.
///
/// 멤버 이름은 기존 `AppColors`와 일치시켰다. 화면 코드는 `AppColors.surface`
/// 대신 `context.p.surface` 로만 바꾸면 두 스킨을 모두 따라간다.
///
/// 두 스킨은 서로 보간하지 않는다([lerp]가 중간에서 한 번에 갈아탄다). 다크
/// 뉴모피즘과 라이트 플랫 사이의 중간 색은 어느 쪽으로도 읽히지 않기 때문이다.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.skin,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceElevated,
    required this.snackBarBg,
    required this.scrim,
    required this.border,
    required this.borderDark,
    required this.borderSubtle,
    required this.borderHighlight,
    required this.borderHighlightDim,
    required this.gradCard,
    required this.gradHeader,
    required this.gradDialog,
    required this.gradInnerCard,
    required this.gradStageLocked,
    required this.gradStageCompleted,
    required this.gradStageCurrent,
    required this.gradStageDefault,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDimmed,
    required this.textDisabled,
    required this.textLocked,
    required this.onAccent,
    required this.blue,
    required this.blue300,
    required this.blue400,
    required this.blue600,
    required this.blue700,
    required this.blue900,
    required this.green,
    required this.green300,
    required this.green400,
    required this.green600,
    required this.green700,
    required this.green900,
    required this.danger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.amber200,
    required this.amber700,
    required this.amber900,
    required this.coinFaceDefault,
    required this.coinRimDefault,
    required this.coinShadowDefault,
    required this.nodeLockedRimTop,
    required this.nodeLockedRimBottom,
    required this.nodeLockedSphereLight,
    required this.nodeLockedSphereMid,
    required this.nodeLockedSphereDark,
    required this.edgeLocked,
    required this.hintBg,
    required this.subjectPalette,
  });

  final AppSkin skin;

  bool get isFlat => skin == AppSkin.flat;

  // ── Surfaces ───────────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceElevated;
  final Color snackBarBg;

  /// 모달 뒤를 덮는 색. 반투명이어야 한다.
  final Color scrim;

  // ── Borders ────────────────────────────────────────────────────
  final Color border;
  final Color borderDark;
  final Color borderSubtle;
  final Color borderHighlight;
  final Color borderHighlightDim;

  // ── Gradients (flat 스킨에서는 단색) ─────────────────────────────
  final LinearGradient gradCard;
  final LinearGradient gradHeader;
  final LinearGradient gradDialog;
  final LinearGradient gradInnerCard;
  final LinearGradient gradStageLocked;
  final LinearGradient gradStageCompleted;
  final LinearGradient gradStageCurrent;
  final LinearGradient gradStageDefault;

  // ── Text ───────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDimmed;
  final Color textDisabled;
  final Color textLocked;

  /// [blue] · [green] 같은 채워진 강조색 위에 올리는 글자·아이콘 색.
  final Color onAccent;

  // ── Blue ───────────────────────────────────────────────────────
  /// 강조 채움 · 테두리.
  final Color blue;

  /// [blue900] 위에 올리는 글자.
  final Color blue300;
  final Color blue400;

  /// 버튼 면.
  final Color blue600;

  /// [blue900] 컨테이너의 테두리.
  final Color blue700;

  /// 옅은(다크에서는 짙은) 컨테이너 배경.
  final Color blue900;

  // ── Green ──────────────────────────────────────────────────────
  final Color green;
  final Color green300;
  final Color green400;
  final Color green600;
  final Color green700;
  final Color green900;

  // ── Danger (오답 · 파괴적 동작) ──────────────────────────────────
  /// 테두리 · 아이콘.
  final Color danger;

  /// 오답 배경.
  final Color dangerContainer;

  /// [dangerContainer] 위에 올리는 글자.
  final Color onDangerContainer;

  // ── Amber ──────────────────────────────────────────────────────
  final Color amber200;
  final Color amber700;
  final Color amber900;

  // ── Coin / badge ───────────────────────────────────────────────
  final Color coinFaceDefault;
  final Color coinRimDefault;
  final Color coinShadowDefault;

  // ── Graph node (locked) ────────────────────────────────────────
  final Color nodeLockedRimTop;
  final Color nodeLockedRimBottom;
  final Color nodeLockedSphereLight;
  final Color nodeLockedSphereMid;
  final Color nodeLockedSphereDark;
  final Color edgeLocked;

  // ── Misc ───────────────────────────────────────────────────────
  final Color hintBg;

  final List<Color> subjectPalette;

  /// 축하 효과는 두 스킨이 공유한다.
  static const List<Color> confetti = [
    Color(0xFFFFD700), Color(0xFF64B5F6), Color(0xFF81C784),
    Color(0xFFF06292), Color(0xFFFFB74D), Color(0xFFBA68C8),
    Color(0xFF4DD0E1), Color(0xFFFF8A65),
  ];

  /// 과목명에서 일관된 강조 색상을 반환한다.
  Color subjectAccent(String subject) {
    int hash = 0;
    for (final r in subject.runes) {
      hash = (hash * 31 + r) & 0x7FFFFFFF;
    }
    return subjectPalette[hash % subjectPalette.length];
  }

  // ── 입체 다크 ───────────────────────────────────────────────────
  static const AppPalette neo = AppPalette(
    skin: AppSkin.neo,
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF252525),
    surfaceElevated: Color(0xFF2A2A2A),
    snackBarBg: Color(0xFF2C2C2C),
    scrim: Color(0xB3000000),
    border: Color(0xFF383838),
    borderDark: Color(0xFF2E2E2E),
    borderSubtle: Color(0xFF484848),
    borderHighlight: Color(0xFF3D3D3D),
    borderHighlightDim: Color(0xFF3A3A3A),
    gradCard: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF272727), Color(0xFF171717)],
    ),
    gradHeader: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF232323), Color(0xFF161616)],
    ),
    gradDialog: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF282828), Color(0xFF181818)],
    ),
    gradInnerCard: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF232323), Color(0xFF141414)],
    ),
    gradStageLocked: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1C1C1C), Color(0xFF111111)],
    ),
    gradStageCompleted: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A2A1A), Color(0xFF101810)],
    ),
    gradStageCurrent: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A1F2A), Color(0xFF10141A)],
    ),
    gradStageDefault: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF252525), Color(0xFF161616)],
    ),
    textPrimary: Color(0xFFEEEEEE),
    textSecondary: Color(0xFF9E9E9E),
    textMuted: Color(0xFF8A8A8A),
    textDimmed: Color(0xFF9A9A9A),
    textDisabled: Color(0xFF565656),
    textLocked: Color(0xFF8E8E8E),
    onAccent: Color(0xFFFFFFFF),
    blue: Color(0xFF2196F3),
    blue300: Color(0xFF64B5F6),
    blue400: Color(0xFF42A5F5),
    blue600: Color(0xFF1E88E5),
    blue700: Color(0xFF1976D2),
    blue900: Color(0xFF0D47A1),
    green: Color(0xFF4CAF50),
    green300: Color(0xFF81C784),
    green400: Color(0xFF66BB6A),
    green600: Color(0xFF43A047),
    green700: Color(0xFF388E3C),
    green900: Color(0xFF1B5E20),
    danger: Color(0xFFF44336),
    dangerContainer: Color(0xFFB71C1C),
    onDangerContainer: Color(0xFFE57373),
    amber200: Color(0xFFFFE082),
    amber700: Color(0xFFFFA000),
    amber900: Color(0xFFFF6F00),
    coinFaceDefault: Color(0xFF3A3A3A),
    coinRimDefault: Color(0xFF505050),
    coinShadowDefault: Color(0xFF282828),
    nodeLockedRimTop: Color(0xFF4A4A4A),
    nodeLockedRimBottom: Color(0xFF181818),
    nodeLockedSphereLight: Color(0xFF3C3C3C),
    nodeLockedSphereMid: Color(0xFF262626),
    nodeLockedSphereDark: Color(0xFF141414),
    edgeLocked: Color(0xFF484848),
    hintBg: Color(0xFF2A2000),
    subjectPalette: [
      Color(0xFF64B5F6), Color(0xFF81C784), Color(0xFFFFB74D),
      Color(0xFFBA68C8), Color(0xFF4DD0E1), Color(0xFFFF8A65),
      Color(0xFFF06292), Color(0xFF9575CD),
    ],
  );

  // ── 플랫 라이트 ─────────────────────────────────────────────────
  //
  // `*900`은 옅은 컨테이너 배경, `*300`은 그 위에 올리는 짙은 글자로 역할이
  // 뒤집힌다. 다크에서 '짙은 배경 + 밝은 글자'였던 쌍이 그대로 유지된다.
  static const AppPalette flat = AppPalette(
    skin: AppSkin.flat,
    background: Color(0xFFF4F6F9),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1F3F6),
    surfaceElevated: Color(0xFFF1F3F6),
    snackBarBg: Color(0xFF14161C),
    scrim: Color(0x8A14161C),
    border: Color(0xFFE3E6EC),
    borderDark: Color(0xFFE3E6EC),
    borderSubtle: Color(0xFFC3C9D4),
    borderHighlight: Color(0xFFE3E6EC),
    borderHighlightDim: Color(0xFFE3E6EC),
    gradCard: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
    gradHeader: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
    gradDialog: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
    gradInnerCard:
        LinearGradient(colors: [Color(0xFFF1F3F6), Color(0xFFF1F3F6)]),
    gradStageLocked:
        LinearGradient(colors: [Color(0xFFF1F3F6), Color(0xFFF1F3F6)]),
    gradStageCompleted:
        LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
    gradStageCurrent:
        LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
    gradStageDefault:
        LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
    textPrimary: Color(0xFF14161C),
    textSecondary: Color(0xFF565C6B),
    textMuted: Color(0xFF565C6B),
    textDimmed: Color(0xFF565C6B),
    textDisabled: Color(0xFF8A92A3),
    // 잠금 상태는 흐린 글자가 아니라 자물쇠 아이콘이 전달한다.
    textLocked: Color(0xFF3A3F4B),
    onAccent: Color(0xFFFFFFFF),
    blue: Color(0xFF2E63E8),
    blue300: Color(0xFF1A3E9C),
    blue400: Color(0xFF2450C8),
    blue600: Color(0xFF2E63E8),
    blue700: Color(0xFFBFD3FC),
    blue900: Color(0xFFDCE7FE),
    green: Color(0xFF0B7E5A),
    green300: Color(0xFF0A6E4E),
    green400: Color(0xFF0B7E5A),
    green600: Color(0xFF0B7E5A),
    green700: Color(0xFFA8DCC7),
    green900: Color(0xFFE7F5EF),
    danger: Color(0xFFC2381F),
    dangerContainer: Color(0xFFFBEBE7),
    onDangerContainer: Color(0xFFA32E19),
    amber200: Color(0xFFF0D9A8),
    amber700: Color(0xFF9A5B08),
    amber900: Color(0xFF7A4708),
    coinFaceDefault: Color(0xFFE3E6EC),
    coinRimDefault: Color(0xFFC3C9D4),
    coinShadowDefault: Color(0xFFC3C9D4),
    nodeLockedRimTop: Color(0xFFC3C9D4),
    nodeLockedRimBottom: Color(0xFFC3C9D4),
    nodeLockedSphereLight: Color(0xFFE9ECF1),
    nodeLockedSphereMid: Color(0xFFE3E6EC),
    nodeLockedSphereDark: Color(0xFFDDE1E8),
    edgeLocked: Color(0xFFE3E6EC),
    hintBg: Color(0xFFFDF4E6),
    subjectPalette: [
      Color(0xFF2E63E8), Color(0xFF0B7E5A), Color(0xFF9A5B08),
      Color(0xFF7B3FA0), Color(0xFF06697A), Color(0xFFB4432A),
      Color(0xFFB32D5E), Color(0xFF5B44B8),
    ],
  );

  static AppPalette of(AppSkin skin) =>
      skin == AppSkin.flat ? AppPalette.flat : AppPalette.neo;

  // 두 스킨은 각각 하나의 완성된 프리셋이라 개별 값을 갈아끼우지 않는다.
  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

/// `context.p.surface` 처럼 쓴다.
extension AppPaletteAccess on BuildContext {
  AppPalette get p =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.neo;
}
