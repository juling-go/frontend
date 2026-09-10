import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _loginWithProvider(String provider) async {
    setState(() => _isLoading = true);
    final user = await _authService.login(
      'mock@email.com',
      'password',
      provider: provider,
    );
    setState(() => _isLoading = false);
    if (user != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
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
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
