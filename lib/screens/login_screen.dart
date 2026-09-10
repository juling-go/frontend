import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../state/app_scope.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

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
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
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
              const Text(
                '서비스 계정으로 로그인 또는 회원가입',
                style: AppTextStyles.dimmedLabel,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => _loginWithProvider('kakao'),
                    child: SvgPicture.asset(
                      'assets/images/kakao.svg',
                      width: AppSpacing.loginButton,
                      height: AppSpacing.loginButton,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => _loginWithProvider('google'),
                    child: SvgPicture.asset(
                      'assets/images/google.svg',
                      width: AppSpacing.loginButton,
                      height: AppSpacing.loginButton,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
