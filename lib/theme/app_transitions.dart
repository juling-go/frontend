import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

// ── 전환 속도 설정 ────────────────────────────────────────────
const Duration kTabTransitionDuration  = Duration(milliseconds: 200);
const Duration kRouteTransitionDuration = Duration(milliseconds: 320);
const Duration kStageLoadingDuration   = Duration(milliseconds: 900);

// ── 탭 전환 애니메이션 ─────────────────────────────────────────
Widget tabTransitionBuilder(Widget child, Animation<double> animation) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
    child: child,
  );
}

// ── 화면 전환 라우트 ───────────────────────────────────────────
PageRouteBuilder<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: kRouteTransitionDuration,
      reverseTransitionDuration: kRouteTransitionDuration,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );

PageRouteBuilder<T> slideUpRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: kRouteTransitionDuration,
      reverseTransitionDuration: kRouteTransitionDuration,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

// ── StageScreen 진입용: 로딩 오버레이 후 화면 전환 ──────────────
Future<T?> pushWithLoadingOverlay<T>({
  required BuildContext context,
  required Widget destination,
  String? title,
  String? subtitle,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    builder: (_) => _StageLoadingOverlay(title: title, subtitle: subtitle),
  );

  await Future.delayed(kStageLoadingDuration);

  if (!context.mounted) return null;
  Navigator.pop(context);
  return Navigator.of(context).push<T>(slideUpRoute(destination));
}

// ── 로딩 오버레이 위젯 ────────────────────────────────────────
class _StageLoadingOverlay extends StatefulWidget {
  final String? title;
  final String? subtitle;

  const _StageLoadingOverlay({this.title, this.subtitle});

  @override
  State<_StageLoadingOverlay> createState() => _StageLoadingOverlayState();
}

class _StageLoadingOverlayState extends State<_StageLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) => Transform.scale(
                scale: 0.92 + _pulse.value * 0.16,
                child: Opacity(
                  opacity: 0.55 + _pulse.value * 0.45,
                  child: child,
                ),
              ),
              child: Container(
                width: AppSpacing.loginIcon,
                height: AppSpacing.loginIcon,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blue900,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.45),
                      blurRadius: AppSpacing.lg,
                      spreadRadius: AppSpacing.s6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: AppSpacing.icon36,
                ),
              ),
            ),
            if (widget.title != null) ...[
              const SizedBox(height: AppSpacing.s22),
              Text(
                widget.title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (widget.subtitle != null) ...[
              const SizedBox(height: AppSpacing.s6),
              Text(
                widget.subtitle!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.s28),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue400),
                minHeight: AppSpacing.s3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
