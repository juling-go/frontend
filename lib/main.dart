import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '주식 학습 앱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue.shade400,
          onPrimary: Colors.white,
          surface: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFEEEEEE),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Color(0xFFEEEEEE),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Color(0xFF9E9E9E),
        ),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: const Color(0xFF383838),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E1E1E)),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2C2C2C),
          contentTextStyle: TextStyle(color: Color(0xFFEEEEEE)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF252525),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const LoginScreen(),
    );
  }
}
