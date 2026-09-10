import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
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
                    icon: const Icon(Icons.settings_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context)
                        .push(slideUpRoute(const SettingsScreen())),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: AppSpacing.avatarSize,
                  height: AppSpacing.avatarSize,
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: AppSpacing.icon48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(user?.name ?? '게스트', style: AppTextStyles.displayLarge),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  width: double.infinity,
                  decoration: card3D(),
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child:
                                Text('학습 등급', style: AppTextStyles.dimmedLabel),
                          ),
                          const Icon(Icons.emoji_events, color: Colors.orange),
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
                          const Expanded(
                            child:
                                Text('학습 목표', style: AppTextStyles.dimmedLabel),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s14,
                                vertical: AppSpacing.s10),
                            decoration: BoxDecoration(
                              color: AppColors.blue900,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.rMd),
                              border: Border.all(color: AppColors.blue700),
                            ),
                            child: const Text(
                              '고수 투자자',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.blue300,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: card3D(),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatColumn(
                          label: '학습한 섹션 수',
                          value: '$completedSections',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 120,
                        color: AppColors.border,
                      ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: AppTextStyles.dimmedLabel, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.s12),
        Container(
          width: AppSpacing.statCircle,
          height: AppSpacing.statCircle,
          decoration: const BoxDecoration(
            color: AppColors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppSpacing.lg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
