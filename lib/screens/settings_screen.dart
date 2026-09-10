import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// 로그아웃 및 회원탈퇴 공통 처리.
  ///
  /// 저장된 로그인 정보와 학습 진행률을 모두 비웁니다. 로그아웃이 끝나면
  /// [AppScope]의 `auth`가 알림을 보내 루트가 로그인 화면으로 바뀌므로,
  /// 여기서는 쌓여 있던 라우트만 정리합니다.
  Future<void> _signOut(BuildContext context) async {
    final scope = AppScope.of(context);
    final navigator = Navigator.of(context);

    await scope.progress.clearAll();
    await scope.auth.logout();

    navigator.popUntil((route) => route.isFirst);
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final danger = context.p.danger;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.p.surface,
        title: const Text('회원탈퇴'),
        content: const Text('정말로 회원탈퇴를 진행하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: danger),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await _signOut(context);
  }

  void _showMockNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$message (Mock)')));
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final auth = scope.auth;
    final p = context.p;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(title: const Text('설정')),
      body: ListenableBuilder(
        listenable: Listenable.merge([auth, scope.skin]),
        builder: (context, _) {
          final user = auth.currentUser;
          final joinDate = user?.joinDate;

          return ListView(
            children: [
              // ── 디자인 ───────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: card3D(
                  context,
                  radius: BorderRadius.circular(AppSpacing.rMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('디자인', style: AppTextStyles.headingMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '두 가지 디자인을 준비했습니다. 바꾸면 앱 전체에 바로 적용됩니다.',
                      style: AppTextStyles.bodySmallMuted(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final skin in AppSkin.values) ...[
                      _SkinOption(
                        skin: skin,
                        selected: scope.skin.skin == skin,
                        onTap: () => scope.skin.setSkin(skin),
                      ),
                      if (skin != AppSkin.values.last)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),

              // ── 계정 ─────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: card3D(
                  context,
                  radius: BorderRadius.circular(AppSpacing.rMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('계정', style: AppTextStyles.headingMedium),
                    const SizedBox(height: AppSpacing.md),
                    _AccountItem(label: '닉네임', value: user?.name ?? '-'),
                    _AccountItem(
                      label: '로그인 방식',
                      value: switch (user?.loginProvider) {
                        'kakao' => '카카오',
                        'google' => '구글',
                        _ => '-',
                      },
                    ),
                    _AccountItem(label: '이메일', value: user?.email ?? '-'),
                    _AccountItem(
                      label: '가입일',
                      value: joinDate == null ? '-' : _formatDate(joinDate),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── 지원 ─────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: card3D(
                  context,
                  radius: BorderRadius.circular(AppSpacing.rMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text('지원', style: AppTextStyles.headingMedium),
                    ),
                    ListTile(
                      title: const Text('도움말 센터'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _showMockNotice(context, '도움말 센터로 이동합니다'),
                    ),
                    const Divider(
                        height: 1,
                        indent: AppSpacing.md,
                        endIndent: AppSpacing.md),
                    ListTile(
                      title: const Text('피드백'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _showMockNotice(context, '피드백 페이지로 이동합니다'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── 약관 및 로그아웃 ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    _LinkButton(
                      title: '규정',
                      onTap: () => _showMockNotice(context, '이용약관을 표시합니다'),
                    ),
                    _LinkButton(
                      title: '개인정보처리방침',
                      onTap: () =>
                          _showMockNotice(context, '개인정보처리방침을 표시합니다'),
                    ),
                    _LinkButton(
                      title: '자료출처',
                      onTap: () =>
                          _showMockNotice(context, '자료출처 정보를 표시합니다'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _signOut(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p.surfaceElevated,
                          foregroundColor: p.textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.rMd),
                            side: p.isFlat
                                ? BorderSide(color: p.border)
                                : BorderSide.none,
                          ),
                        ),
                        child: const Text('로그아웃'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 되돌릴 수 없는 동작은 계정 카드 안의 눈에 띄는 버튼이
                    // 아니라 화면 맨 아래 조용한 링크로 둡니다.
                    Center(
                      child: TextButton(
                        onPressed: () => _confirmDeleteAccount(context),
                        style: TextButton.styleFrom(
                          foregroundColor: p.textSecondary,
                        ),
                        child: Text(
                          '회원탈퇴',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: p.textSecondary,
                            decoration: TextDecoration.underline,
                            decorationColor: p.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }
}

/// 디자인 하나를 고르는 줄.
class _SkinOption extends StatelessWidget {
  final AppSkin skin;
  final bool selected;
  final VoidCallback onTap;

  const _SkinOption({
    required this.skin,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.p;
    final radius = BorderRadius.circular(AppSpacing.rMd);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      child: Material(
        color: selected ? p.blue900 : p.surfaceVariant,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.s12,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? p.blue : p.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: AppSpacing.iconMd,
                  color: selected ? p.blue300 : p.textSecondary,
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skin.label,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: selected ? p.blue300 : p.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        skin.description,
                        style: AppTextStyles.captionMuted(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final String label;
  final String value;

  const _AccountItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.dimmedLabel(context)),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LinkButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          foregroundColor: context.p.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: Text(title, style: AppTextStyles.bodyLarge),
      ),
    );
  }
}
