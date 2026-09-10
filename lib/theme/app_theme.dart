import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_spacing.dart';

export 'app_palette.dart' show AppSkin, AppPalette, AppPaletteAccess;

// ── ThemeData ────────────────────────────────────────────────
ThemeData buildAppTheme(AppSkin skin) {
  final p = AppPalette.of(skin);
  // BuildContext가 없는 자리(CustomPainter 등)에서 읽는 AppColors도 같은
  // 팔레트를 보도록, 테마를 만들 때 함께 갱신합니다. MaterialApp이 만들어지기
  // 전이라 어떤 위젯이 그려지기 전에 항상 최신 값이 꽂힙니다.
  AppColors.bind(p);

  final isFlat = skin == AppSkin.flat;
  final brightness = isFlat ? Brightness.light : Brightness.dark;

  final scheme = isFlat
      ? ColorScheme.light(
          primary: p.blue,
          onPrimary: p.onAccent,
          secondary: p.green,
          onSecondary: p.onAccent,
          surface: p.surface,
          onSurface: p.textPrimary,
          outline: p.borderSubtle,
          outlineVariant: p.border,
        )
      : ColorScheme.dark(
          primary: p.blue400,
          onPrimary: p.onAccent,
          secondary: p.green400,
          onSecondary: p.onAccent,
          surface: p.surface,
          onSurface: p.textPrimary,
          outline: p.borderSubtle,
          outlineVariant: p.border,
        );

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    extensions: <ThemeExtension<dynamic>>[p],
    scaffoldBackgroundColor: p.background,
    appBarTheme: AppBarTheme(
      backgroundColor: isFlat ? p.background : p.surface,
      foregroundColor: p.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: p.surface,
      selectedItemColor: p.blue,
      unselectedItemColor: p.textSecondary,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      elevation: 0,
    ),
    cardColor: p.surface,
    dividerColor: p.border,
    dialogTheme: DialogThemeData(backgroundColor: p.surface),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.snackBarBg,
      contentTextStyle: TextStyle(color: isFlat ? p.background : p.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceVariant,
    ),
    useMaterial3: true,
  );
}

// ── 카드 데코레이션 ───────────────────────────────────────────
/// 입체 다크에서는 그라데이션 + 안쪽 하이라이트 + 깊은 그림자,
/// 플랫 라이트에서는 단색 표면 + 1px 테두리 + 옅은 그림자.
BoxDecoration card3D(
  BuildContext context, {
  BorderRadius? radius,
  Border? border,
}) {
  final p = context.p;
  final r = radius ?? BorderRadius.circular(AppSpacing.rLg);

  if (p.isFlat) {
    return BoxDecoration(
      color: p.surface,
      borderRadius: r,
      border: border ?? Border.all(color: p.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A14161C),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
        BoxShadow(
          color: Color(0x0F14161C),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  return BoxDecoration(
    gradient: p.gradCard,
    borderRadius: r,
    border: border,
    boxShadow: [
      BoxShadow(
        color: p.borderHighlight,
        blurRadius: 5,
        offset: const Offset(-2, -2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.6),
        blurRadius: 14,
        offset: const Offset(5, 7),
      ),
    ],
  );
}

// ── 헤더 데코레이션 ───────────────────────────────────────────
BoxDecoration headerDecoration(BuildContext context) {
  final p = context.p;

  if (p.isFlat) {
    return BoxDecoration(
      color: p.surface,
      border: Border(bottom: BorderSide(color: p.border)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F14161C),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  return BoxDecoration(
    gradient: p.gradHeader,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.55),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: p.borderHighlightDim,
        blurRadius: 4,
        offset: const Offset(-1, -1),
      ),
    ],
  );
}

// ── 주요 버튼 ────────────────────────────────────────────────
/// 입체 다크에서는 아래쪽 3px 턱이 보이는 입체 버튼, 플랫 라이트에서는
/// 평면 버튼으로 그린다.
///
/// 두 스킨 모두 [InkWell] 위에 올라가므로 리플·포커스·버튼 시맨틱이 붙는다.
/// (기존 구현은 [GestureDetector]라 스크린리더가 버튼으로 읽지 못했다.)
Widget raised3DButton({
  required BuildContext context,
  required Widget child,
  required Color shadowColor,
  required Color faceColor,
  required BorderRadius borderRadius,
  EdgeInsets? padding,
  VoidCallback? onTap,
  String? semanticLabel,
}) {
  final p = context.p;
  final resolvedPadding = padding ??
      const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s9,
      );

  Widget face = Material(
    color: faceColor,
    borderRadius: borderRadius,
    child: InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(padding: resolvedPadding, child: child),
    ),
  );

  if (!p.isFlat) {
    // 아래쪽 3px만큼 그림자 색이 드러나 턱처럼 보인다.
    face = Container(
      decoration: BoxDecoration(
        color: shadowColor,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s3),
        child: face,
      ),
    );
  }

  return Semantics(
    button: true,
    label: semanticLabel,
    child: face,
  );
}
