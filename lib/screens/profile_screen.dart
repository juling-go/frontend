import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../theme/app_transitions.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  /// 완료한 섹션 수를 계산하려면 커리큘럼 구조가 필요합니다.
  final List<Curriculum> curriculums;

  const ProfileScreen({super.key, this.curriculums = const []});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final p = context.p;

    return ListenableBuilder(
      listenable: Listenable.merge([scope.auth, scope.progress]),
      builder: (context, _) {
        final user = scope.auth.currentUser;
        final completedStages = scope.progress.totalCompletedStages;
        final completedSections =
            scope.progress.totalCompletedNodes(curriculums);

        return SingleChildScrollView(
          child: Column(
            children: [
              // ── 설정 진입점 ──────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: AppSpacing.sm, right: AppSpacing.sm),
                  child: IconButton(
                    tooltip: '설정',
                    icon: Icon(Icons.settings_outlined, color: p.textSecondary),
                    onPressed: () => Navigator.of(context)
                        .push(slideUpRoute(const SettingsScreen())),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: AppSpacing.avatarSize,
                  height: AppSpacing.avatarSize,
                  decoration: BoxDecoration(
                    color: p.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: p.onAccent,
                    size: AppSpacing.icon48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(user?.name ?? '게스트', style: AppTextStyles.displayLarge),
              const SizedBox(height: AppSpacing.lg),

              // ── 등급 · 목표 ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  width: double.infinity,
                  decoration: card3D(context),
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('학습 등급',
                                style: AppTextStyles.dimmedLabel(context)),
                          ),
                          Icon(Icons.emoji_events, color: p.amber700),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _gradeFor(completedStages),
                            style: AppTextStyles.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Text('학습 목표',
                                style: AppTextStyles.dimmedLabel(context)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s14,
                                vertical: AppSpacing.s10),
                            decoration: BoxDecoration(
                              color: p.blue900,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.rMd),
                              border: Border.all(color: p.blue700),
                            ),
                            child: Text(
                              '고수 투자자',
                              style: AppTextStyles.body.copyWith(
                                color: p.blue300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 학습량 ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  width: double.infinity,
                  // 고정 높이를 두지 않습니다. 시스템 글자 크기를 키워도
                  // 카드가 늘어날 뿐 잘리지 않습니다.
                  decoration: card3D(context),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _StatColumn(
                            label: '학습한 섹션 수',
                            value: '$completedSections',
                          ),
                        ),
                        Container(width: 1, color: p.border),
                        Expanded(
                          child: _StatColumn(
                            label: '학습한 스테이지 수',
                            value: '$completedStages',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s36),
            ],
          ),
        );
      },
    );
  }

  /// 완료한 스테이지 수로 등급을 매깁니다.
  static String _gradeFor(int completedStages) {
    if (completedStages >= 30) return '플래티넘';
    if (completedStages >= 20) return '골드';
    if (completedStages >= 10) return '실버';
    if (completedStages >= 1) return '브론즈';
    return '입문';
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.p;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.dimmedLabel(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s12),
        if (p.isFlat)
          // 플랫에서는 숫자 자체를 크게 씁니다. 원을 씌우면 큰 숫자가
          // 원 밖으로 밀려나기 때문입니다.
          Text(
            value,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 34,
              height: 1.2,
              letterSpacing: -0.5,
              color: p.blue,
            ),
          )
        else
          Container(
            width: AppSpacing.statCircle,
            height: AppSpacing.statCircle,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.blue,
              shape: BoxShape.circle,
            ),
            child: Text(
              value,
              style: AppTextStyles.displayLarge.copyWith(color: p.onAccent),
            ),
          ),
      ],
    );
  }
}
