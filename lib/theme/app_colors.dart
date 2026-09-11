import 'package:flutter/material.dart';

import 'app_palette.dart';

/// 현재 선택된 디자인의 색을 정적으로 노출하는 호환 계층입니다.
///
/// 색의 실제 값은 [AppPalette]가 가지고 있습니다. 이 클래스는 `AppColors.surface`
/// 형태로 색을 읽던 기존 코드가 스킨 전환을 그대로 따라가도록 중계만 합니다.
///
/// **새 코드는 `context.p.surface`를 쓰세요.** 그쪽이 위젯 트리에서 값을 받는
/// 정석이고, 테마가 둘 이상 겹칠 때도 올바르게 동작합니다. 이 정적 접근은
/// [CustomPainter]나 `BuildContext`가 없는 헬퍼처럼 트리에서 값을 받을 수 없는
/// 자리를 위해 남겨 둔 것이며, 그런 곳부터 점진적으로 걷어내면 됩니다.
///
/// [bind]는 `buildAppTheme()`이 테마를 만들 때 호출합니다. 루트의
/// `ListenableBuilder`가 `MaterialApp`을 만들기 전에 실행되므로, 어떤 위젯이
/// 그려지기 전에 항상 최신 팔레트가 꽂혀 있습니다.
class AppColors {
  AppColors._();

  static AppPalette _current = AppPalette.neo;

  /// 현재 팔레트. `buildAppTheme()`이 갱신합니다.
  static AppPalette get current => _current;

  static void bind(AppPalette palette) => _current = palette;

  // ── Surfaces ─────────────────────────────────────────────────
  static Color get background => _current.background;
  static Color get surface => _current.surface;
  static Color get surfaceVariant => _current.surfaceVariant;
  static Color get surfaceElevated => _current.surfaceElevated;
  static Color get snackBarBg => _current.snackBarBg;
  static Color get scrim => _current.scrim;

  // ── Borders ──────────────────────────────────────────────────
  static Color get border => _current.border;
  static Color get borderDark => _current.borderDark;
  static Color get borderSubtle => _current.borderSubtle;
  static Color get borderHighlight => _current.borderHighlight;
  static Color get borderHighlightDim => _current.borderHighlightDim;

  // ── Gradients ────────────────────────────────────────────────
  static LinearGradient get gradCard => _current.gradCard;
  static LinearGradient get gradHeader => _current.gradHeader;
  static LinearGradient get gradDialog => _current.gradDialog;
  static LinearGradient get gradInnerCard => _current.gradInnerCard;
  static LinearGradient get gradStageLocked => _current.gradStageLocked;
  static LinearGradient get gradStageCompleted => _current.gradStageCompleted;
  static LinearGradient get gradStageCurrent => _current.gradStageCurrent;
  static LinearGradient get gradStageDefault => _current.gradStageDefault;

  // ── Text ─────────────────────────────────────────────────────
  static Color get textPrimary => _current.textPrimary;
  static Color get textSecondary => _current.textSecondary;
  static Color get textMuted => _current.textMuted;
  static Color get textDimmed => _current.textDimmed;
  static Color get textDisabled => _current.textDisabled;
  static Color get textLocked => _current.textLocked;

  /// 채워진 강조색 위에 올리는 글자·아이콘 색.
  static Color get onAccent => _current.onAccent;

  // ── Blue ─────────────────────────────────────────────────────
  static Color get blue => _current.blue;
  static Color get blue300 => _current.blue300;
  static Color get blue400 => _current.blue400;
  static Color get blue600 => _current.blue600;
  static Color get blue700 => _current.blue700;
  static Color get blue900 => _current.blue900;

  // ── Green ────────────────────────────────────────────────────
  static Color get green => _current.green;
  static Color get green300 => _current.green300;
  static Color get green400 => _current.green400;
  static Color get green600 => _current.green600;
  static Color get green700 => _current.green700;
  static Color get green900 => _current.green900;

  // ── Danger ───────────────────────────────────────────────────
  static Color get danger => _current.danger;
  static Color get dangerContainer => _current.dangerContainer;
  static Color get onDangerContainer => _current.onDangerContainer;

  // ── Amber ────────────────────────────────────────────────────
  static Color get amber200 => _current.amber200;
  static Color get amber700 => _current.amber700;
  static Color get amber900 => _current.amber900;

  // ── Coin / badge ─────────────────────────────────────────────
  static Color get coinFaceDefault => _current.coinFaceDefault;
  static Color get coinRimDefault => _current.coinRimDefault;
  static Color get coinShadowDefault => _current.coinShadowDefault;

  // ── Graph node locked ────────────────────────────────────────
  static Color get nodeLockedRimTop => _current.nodeLockedRimTop;
  static Color get nodeLockedRimBottom => _current.nodeLockedRimBottom;
  static Color get nodeLockedSphereLight => _current.nodeLockedSphereLight;
  static Color get nodeLockedSphereMid => _current.nodeLockedSphereMid;
  static Color get nodeLockedSphereDark => _current.nodeLockedSphereDark;
  static Color get edgeLocked => _current.edgeLocked;

  // ── Misc ─────────────────────────────────────────────────────
  static Color get hintBg => _current.hintBg;

  /// 브랜드 색이므로 스킨과 무관하게 고정입니다.
  static const Color kakaoYellow = Color(0xFFFEE500);

  // ── Palettes ─────────────────────────────────────────────────
  static List<Color> get subjectPalette => _current.subjectPalette;

  static const List<Color> confetti = AppPalette.confetti;

  /// 과목명에서 일관된 강조 색상 반환
  static Color subjectAccent(String subject) =>
      _current.subjectAccent(subject);
}
