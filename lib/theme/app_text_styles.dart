import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Headings ─────────────────────────────────────────────────
  static const TextStyle displayLarge  = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle displayMedium = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const TextStyle headingLarge  = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle headingMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const TextStyle headingSmall  = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  static const TextStyle titleLarge    = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static const TextStyle titleMedium   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle titleSmall    = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

  // ── Body ─────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(fontSize: 15);
  static const TextStyle body      = TextStyle(fontSize: 14, height: 1.4);
  static const TextStyle bodySmall = TextStyle(fontSize: 13, height: 1.4);
  static const TextStyle caption   = TextStyle(fontSize: 12);
  static const TextStyle captionMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle captionSmall  = TextStyle(fontSize: 11);
  static const TextStyle label         = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5);

  // ── With color ───────────────────────────────────────────────
  static const TextStyle bodySmallMuted    = TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4);
  static const TextStyle bodyMuted         = TextStyle(fontSize: 14, color: AppColors.textSecondary);
  static const TextStyle captionMuted      = TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const TextStyle captionSmallMuted = TextStyle(fontSize: 11, color: AppColors.textMuted);
  static const TextStyle breadcrumb        = TextStyle(fontSize: 11, color: AppColors.textMuted);
  static const TextStyle dimmedLabel       = TextStyle(fontSize: 16, color: AppColors.textSecondary);

  // ── Stage / quiz specific ────────────────────────────────────
  static const TextStyle question = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5);
  static const TextStyle oxButton = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
}
