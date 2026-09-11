import 'package:flutter/material.dart';

import 'app_palette.dart';

/// 타이포 스케일.
///
/// 색이 필요한 스타일은 스킨에 따라 달라지므로 `const`가 아니라 [BuildContext]를
/// 받는 함수로 제공한다. 색이 없는 스타일은 그대로 `const`로 두어 호출부의
/// `const` 위젯을 깨지 않는다.
///
/// 한글은 자모가 쌓여 세로로 꽉 차기 때문에 행간(`height`)이 1.35 아래로
/// 내려가면 두 줄부터 답답해진다. 본문 계열에는 모두 행간을 준다.
class AppTextStyles {
  AppTextStyles._();

  // ── Headings ─────────────────────────────────────────────────
  static const TextStyle displayLarge =
      TextStyle(fontSize: 24, height: 1.35, fontWeight: FontWeight.bold);
  static const TextStyle displayMedium =
      TextStyle(fontSize: 22, height: 1.36, fontWeight: FontWeight.bold);
  static const TextStyle headingLarge =
      TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.bold);
  static const TextStyle headingMedium =
      TextStyle(fontSize: 18, height: 1.44, fontWeight: FontWeight.bold);
  static const TextStyle headingSmall =
      TextStyle(fontSize: 17, height: 1.41, fontWeight: FontWeight.bold);
  static const TextStyle titleLarge =
      TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.bold);
  static const TextStyle titleMedium =
      TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600);
  static const TextStyle titleSmall =
      TextStyle(fontSize: 15, height: 1.47, fontWeight: FontWeight.w600);

  // ── Body ─────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(fontSize: 15, height: 1.5);
  static const TextStyle body = TextStyle(fontSize: 14, height: 1.45);
  static const TextStyle bodySmall = TextStyle(fontSize: 13, height: 1.45);
  static const TextStyle caption = TextStyle(fontSize: 12, height: 1.5);
  static const TextStyle captionMedium =
      TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w500);
  static const TextStyle captionSmall = TextStyle(fontSize: 11, height: 1.45);
  static const TextStyle label = TextStyle(
      fontSize: 11, height: 1.45, fontWeight: FontWeight.w600, letterSpacing: 0.5);

  // ── Stage / quiz specific ────────────────────────────────────
  static const TextStyle question =
      TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w600);
  static const TextStyle oxButton =
      TextStyle(fontSize: 32, height: 1.1, fontWeight: FontWeight.bold);

  // ── With color (스킨에 따라 달라짐) ────────────────────────────
  static TextStyle bodySmallMuted(BuildContext context) =>
      bodySmall.copyWith(color: context.p.textSecondary);

  static TextStyle bodyMuted(BuildContext context) =>
      body.copyWith(color: context.p.textSecondary);

  static TextStyle captionMuted(BuildContext context) =>
      caption.copyWith(color: context.p.textSecondary);

  static TextStyle captionSmallMuted(BuildContext context) =>
      captionSmall.copyWith(color: context.p.textMuted);

  static TextStyle breadcrumb(BuildContext context) =>
      captionSmall.copyWith(color: context.p.textMuted);

  static TextStyle dimmedLabel(BuildContext context) =>
      const TextStyle(fontSize: 16, height: 1.5)
          .copyWith(color: context.p.textSecondary);
}
