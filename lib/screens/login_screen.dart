import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// 카카오 말풍선 심볼.
///
/// `assets/images/kakao.svg`는 노란 원형 배경까지 포함한 194 path짜리 파일이라
/// 노란 버튼 위에 올리면 노랑 위 노랑이 된다. 플랫 스킨의 가로 버튼에서는
/// 이 심볼만 쓰고, 입체 다크의 원형 버튼에서는 에셋을 그대로 쓴다.
const String _kakaoSymbolSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path fill="#000000" fill-opacity="0.85" d="M12 3.4c-4.86 0-8.8 3.09-8.8 6.9 0 2.44 1.62 4.58 4.05 5.79-.18.65-.65 2.37-.74 2.74-.12.46.17.45.35.33.14-.09 2.29-1.55 3.22-2.18.62.09 1.26.14 1.92.14 4.86 0 8.8-3.09 8.8-6.9S16.86 3.4 12 3.4z"/>
</svg>
''';

const Color _kakaoYellow = Color(0xFFFEE500);
const Color _kakaoLabel = Color(0xD9000000); // 검정 85%

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _loginWithProvider(String provider) async {
    setState(() => _isLoading = true);
    final user = await AppScope.of(context).auth.login(provider);
    if (!mounted) return;
    setState(() => _isLoading = false);
    // 로그인에 성공하면 AuthRepository의 알림을 받아 루트가 HomeScreen으로
    // 교체되므로, 여기서 직접 화면을 밀어 넣지 않습니다.
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인 실패')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.p;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: AppSpacing.loginIcon,
                height: AppSpacing.loginIcon,
                decoration: BoxDecoration(
                  color: p.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up,
                  color: p.onAccent,
                  size: AppSpacing.icon40,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                '투자 학습앱 주링고',
                style: AppTextStyles.displayLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              Text(
                '서비스 계정으로 로그인 또는 회원가입',
                style: AppTextStyles.dimmedLabel(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (p.isFlat) _flatButtons(context) else _circleButtons(context),
              const Spacer(flex: 2),
              // 자리를 항상 차지해 로딩이 시작돼도 위 내용이 밀리지 않습니다.
              SizedBox(
                height: AppSpacing.s40,
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: AppSpacing.iconLg,
                          height: AppSpacing.iconLg,
                          child: CircularProgressIndicator(strokeWidth: 2.6),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  /// 플랫 라이트: 전체 너비 버튼 + 로고 + 문구.
  Widget _flatButtons(BuildContext context) {
    final p = context.p;
    return Column(
      children: [
        _WideSocialButton(
          label: '카카오로 시작하기',
          background: _kakaoYellow,
          foreground: _kakaoLabel,
          icon: SvgPicture.string(_kakaoSymbolSvg,
              width: AppSpacing.icon22, height: AppSpacing.icon22),
          onTap: _isLoading ? null : () => _loginWithProvider('kakao'),
        ),
        const SizedBox(height: AppSpacing.s12),
        _WideSocialButton(
          label: 'Google로 시작하기',
          background: p.surface,
          foreground: p.textPrimary,
          border: p.borderSubtle,
          icon: SvgPicture.asset('assets/images/google.svg',
              width: AppSpacing.iconLg, height: AppSpacing.iconLg),
          onTap: _isLoading ? null : () => _loginWithProvider('google'),
        ),
      ],
    );
  }

  /// 입체 다크: 원형 브랜드 마크. 모양은 그대로 두되 시맨틱을 갖는 버튼으로 감쌉니다.
  Widget _circleButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleSocialButton(
          label: '카카오로 시작하기',
          asset: 'assets/images/kakao.svg',
          onTap: _isLoading ? null : () => _loginWithProvider('kakao'),
        ),
        const SizedBox(width: AppSpacing.lg),
        _CircleSocialButton(
          label: 'Google로 시작하기',
          asset: 'assets/images/google.svg',
          onTap: _isLoading ? null : () => _loginWithProvider('google'),
        ),
      ],
    );
  }
}

class _WideSocialButton extends StatelessWidget {
  const _WideSocialButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
  });

  final String label;
  final Widget icon;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // ElevatedButton + Text 조합이 버튼 시맨틱과 라벨을 함께 제공합니다.
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: background,
        disabledForegroundColor: foreground,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        side: border == null ? BorderSide.none : BorderSide(color: border!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r14),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ExcludeSemantics(child: icon),
          ),
          Text(
            label,
            style: AppTextStyles.titleMedium.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _CircleSocialButton extends StatelessWidget {
  const _CircleSocialButton({
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // IconButton이 버튼 시맨틱·리플·포커스·최소 터치 영역을 모두 제공하고,
    // tooltip이 스크린리더가 읽을 라벨이 됩니다.
    return IconButton(
      onPressed: onTap,
      tooltip: label,
      padding: EdgeInsets.zero,
      iconSize: AppSpacing.loginButton,
      constraints: const BoxConstraints(
        minWidth: AppSpacing.loginButton,
        minHeight: AppSpacing.loginButton,
      ),
      icon: SvgPicture.asset(
        asset,
        width: AppSpacing.loginButton,
        height: AppSpacing.loginButton,
      ),
    );
  }
}
