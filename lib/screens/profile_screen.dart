import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
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
          const Text('Mock User', style: AppTextStyles.displayLarge),
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
                        child: Text('학습 등급', style: AppTextStyles.dimmedLabel),
                      ),
                      const Icon(Icons.emoji_events, color: Colors.orange),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('골드', style: AppTextStyles.titleMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('학습 목표', style: AppTextStyles.dimmedLabel),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s14, vertical: AppSpacing.s10),
                        decoration: BoxDecoration(
                          color: AppColors.blue900,
                          borderRadius: BorderRadius.circular(AppSpacing.rMd),
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
                  Expanded(child: _StatColumn(label: '학습한 섹션 수', value: '8')),
                  Container(
                    width: 1,
                    height: 120,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: _StatColumn(label: '학습한 스테이지 수', value: '24'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s36),
        ],
      ),
    );
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
