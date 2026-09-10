import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Surfaces ─────────────────────────────────────────────────
  static const Color background      = Color(0xFF121212);
  static const Color surface         = Color(0xFF1E1E1E);
  static const Color surfaceVariant  = Color(0xFF252525);
  static const Color surfaceElevated = Color(0xFF2A2A2A);
  static const Color snackBarBg      = Color(0xFF2C2C2C);

  // ── Borders ──────────────────────────────────────────────────
  static const Color border              = Color(0xFF383838);
  static const Color borderDark          = Color(0xFF2E2E2E);
  static const Color borderSubtle        = Color(0xFF484848);
  static const Color borderHighlight     = Color(0xFF3D3D3D);
  static const Color borderHighlightDim  = Color(0xFF3A3A3A);

  // ── Gradients ────────────────────────────────────────────────
  static const LinearGradient gradCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF272727), Color(0xFF171717)],
  );
  static const LinearGradient gradHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF232323), Color(0xFF161616)],
  );
  static const LinearGradient gradDialog = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF282828), Color(0xFF181818)],
  );
  static const LinearGradient gradInnerCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF232323), Color(0xFF141414)],
  );

  // Stage state gradients
  static const LinearGradient gradStageLocked = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C1C), Color(0xFF111111)],
  );
  static const LinearGradient gradStageCompleted = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1A2A1A), Color(0xFF101810)],
  );
  static const LinearGradient gradStageCurrent = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F2A), Color(0xFF10141A)],
  );
  static const LinearGradient gradStageDefault = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF252525), Color(0xFF161616)],
  );

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted     = Color(0xFF8A8A8A);
  static const Color textDimmed    = Color(0xFF686868);
  static const Color textDisabled  = Color(0xFF565656);
  static const Color textLocked    = Color(0xFF707070);

  // ── Blue palette ─────────────────────────────────────────────
  static const Color blue    = Color(0xFF2196F3);
  static const Color blue300 = Color(0xFF64B5F6);
  static const Color blue400 = Color(0xFF42A5F5);
  static const Color blue600 = Color(0xFF1E88E5);
  static const Color blue700 = Color(0xFF1976D2);
  static const Color blue900 = Color(0xFF0D47A1);

  // ── Green palette ────────────────────────────────────────────
  static const Color green    = Color(0xFF4CAF50);
  static const Color green300 = Color(0xFF81C784);
  static const Color green400 = Color(0xFF66BB6A);
  static const Color green600 = Color(0xFF43A047);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green900 = Color(0xFF1B5E20);

  // ── Amber palette ────────────────────────────────────────────
  static const Color amber200 = Color(0xFFFFE082);
  static const Color amber700 = Color(0xFFFFA000);
  static const Color amber900 = Color(0xFFFF6F00);

  // ── Coin / badge ─────────────────────────────────────────────
  static const Color coinFaceDefault   = Color(0xFF3A3A3A);
  static const Color coinRimDefault    = Color(0xFF505050);
  static const Color coinShadowDefault = Color(0xFF282828);

  // ── Graph node locked ────────────────────────────────────────
  static const Color nodeLockedRimTop      = Color(0xFF4A4A4A);
  static const Color nodeLockedRimBottom   = Color(0xFF181818);
  static const Color nodeLockedSphereLight = Color(0xFF3C3C3C);
  static const Color nodeLockedSphereMid   = Color(0xFF262626);
  static const Color nodeLockedSphereDark  = Color(0xFF141414);
  static const Color edgeLocked            = Color(0xFF484848);

  // ── Misc ─────────────────────────────────────────────────────
  static const Color hintBg      = Color(0xFF2A2000);
  static const Color kakaoYellow = Color(0xFFFEE500);

  // ── Palettes ─────────────────────────────────────────────────
  static const List<Color> subjectPalette = [
    Color(0xFF64B5F6), Color(0xFF81C784), Color(0xFFFFB74D),
    Color(0xFFBA68C8), Color(0xFF4DD0E1), Color(0xFFFF8A65),
    Color(0xFFF06292), Color(0xFF9575CD),
  ];

  static const List<Color> confetti = [
    Color(0xFFFFD700), Color(0xFF64B5F6), Color(0xFF81C784),
    Color(0xFFF06292), Color(0xFFFFB74D), Color(0xFFBA68C8),
    Color(0xFF4DD0E1), Color(0xFFFF8A65),
  ];

  // ── Helpers ──────────────────────────────────────────────────
  /// 과목명에서 일관된 강조 색상 반환
  static Color subjectAccent(String subject) {
    int hash = 0;
    for (final r in subject.runes) {
      hash = (hash * 31 + r) & 0x7FFFFFFF;
    }
    return subjectPalette[hash % subjectPalette.length];
  }
}
