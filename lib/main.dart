import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'state/app_scope.dart';
import 'state/auth_repository.dart';
import 'state/progress_repository.dart';
import 'state/skin_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MyApp(
      auth: AuthRepository(prefs),
      progress: ProgressRepository(prefs),
      skin: SkinController(prefs),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthRepository auth;
  final ProgressRepository progress;

  /// 넘기지 않으면 저장 없이 기본 디자인으로 시작합니다.
  final SkinController? skin;

  const MyApp({
    super.key,
    required this.auth,
    required this.progress,
    this.skin,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SkinController _skin = widget.skin ?? SkinController();

  @override
  void dispose() {
    // 밖에서 주입받은 컨트롤러의 수명은 주입한 쪽이 관리합니다.
    if (widget.skin == null) _skin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      auth: widget.auth,
      progress: widget.progress,
      skin: _skin,
      // 디자인을 바꾸면 테마 전체를 다시 만듭니다.
      child: ListenableBuilder(
        listenable: _skin,
        builder: (context, _) {
          final theme = buildAppTheme(_skin.skin);
          return MaterialApp(
            title: '주식 학습 앱',
            // 스킨이 밝기까지 결정하므로 light/dark 양쪽에 같은 테마를 주고
            // themeMode는 고정합니다. 시스템 설정이 디자인을 덮어쓰지 않습니다.
            theme: theme,
            darkTheme: theme,
            themeMode: _skin.skin == AppSkin.flat
                ? ThemeMode.light
                : ThemeMode.dark,
            // 저장된 로그인 정보가 있으면 로그인 화면을 건너뜁니다.
            home: ListenableBuilder(
              listenable: widget.auth,
              builder: (context, _) =>
                  widget.auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
            ),
          );
        },
      ),
    );
  }
}
