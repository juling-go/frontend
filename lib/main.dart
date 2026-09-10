import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'state/app_scope.dart';
import 'state/auth_repository.dart';
import 'state/progress_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MyApp(
      auth: AuthRepository(prefs),
      progress: ProgressRepository(prefs),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository auth;
  final ProgressRepository progress;

  const MyApp({super.key, required this.auth, required this.progress});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      auth: auth,
      progress: progress,
      child: MaterialApp(
        title: '주식 학습 앱',
        // 다크 전용 앱이지만, themeMode가 바뀌어도 팔레트가 깨지지 않도록
        // light/dark 양쪽에 같은 테마를 지정합니다.
        theme: buildAppTheme(),
        darkTheme: buildAppTheme(),
        themeMode: ThemeMode.dark,
        // 저장된 로그인 정보가 있으면 로그인 화면을 건너뜁니다.
        home: ListenableBuilder(
          listenable: auth,
          builder: (context, _) =>
              auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      ),
    );
  }
}
