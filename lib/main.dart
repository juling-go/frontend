import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '주식 학습 앱',
      darkTheme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      home: const LoginScreen(),
    );
  }
}
