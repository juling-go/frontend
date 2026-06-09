import 'package:flutter/material.dart';

// ── 전환 속도 설정 ────────────────────────────────────────────
// 여기 값만 바꾸면 전체 앱 전환 속도가 변경됩니다.
const Duration kTabTransitionDuration = Duration(milliseconds: 200);
const Duration kRouteTransitionDuration = Duration(milliseconds: 320);
const Duration kStageLoadingDuration = Duration(milliseconds: 900);

// ── 탭 전환 애니메이션 ─────────────────────────────────────────
// AnimatedSwitcher의 transitionBuilder에 전달합니다.
// 다른 효과로 바꾸려면 이 함수만 수정하세요.
Widget tabTransitionBuilder(Widget child, Animation<double> animation) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
    child: child,
  );
}

// ── 화면 전환 라우트 ───────────────────────────────────────────
// 필요에 따라 fadeRoute / slideUpRoute 중 선택해서 사용하세요.

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
// 디자인을 바꾸고 싶다면 이 위젯만 수정하세요.
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade900,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            if (widget.title != null) ...[
              const SizedBox(height: 22),
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
              const SizedBox(height: 6),
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
