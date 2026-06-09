import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

// ── ThemeData ────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.blue400,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.blue,
      unselectedItemColor: AppColors.textSecondary,
    ),
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.snackBarBg,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
    ),
    useMaterial3: true,
  );
}

// ── 카드 데코레이션 ───────────────────────────────────────────
BoxDecoration card3D({BorderRadius? radius, Border? border}) {
  return BoxDecoration(
    gradient: AppColors.gradCard,
    borderRadius: radius ?? BorderRadius.circular(AppSpacing.rLg),
    border: border,
    boxShadow: [
      const BoxShadow(
        color: AppColors.borderHighlight,
        blurRadius: 5,
        offset: Offset(-2, -2),
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
BoxDecoration headerDecoration() {
  return BoxDecoration(
    gradient: AppColors.gradHeader,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.55),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
      const BoxShadow(
        color: AppColors.borderHighlightDim,
        blurRadius: 4,
        offset: Offset(-1, -1),
      ),
    ],
  );
}

// ── 3D 버튼 ──────────────────────────────────────────────────
Widget raised3DButton({
  required Widget child,
  required Color shadowColor,
  required Color faceColor,
  required BorderRadius borderRadius,
  EdgeInsets? padding,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(color: shadowColor, borderRadius: borderRadius),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        padding: padding ??
            const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.s9),
        decoration: BoxDecoration(color: faceColor, borderRadius: borderRadius),
        child: child,
      ),
    ),
  );
}
