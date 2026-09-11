import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:julingo/main.dart';
import 'package:julingo/screens/home_screen.dart';
import 'package:julingo/screens/login_screen.dart';
import 'package:julingo/state/auth_repository.dart';
import 'package:julingo/state/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester, SharedPreferences prefs) async {
  await tester.pumpWidget(
    MyApp(
      auth: AuthRepository(prefs),
      progress: ProgressRepository(prefs),
    ),
  );
  // mock 서비스의 지연(300ms)과 자산 로딩을 통과시킵니다.
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('저장된 로그인 정보가 없으면 로그인 화면으로 시작한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await _pumpApp(tester, prefs);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.text('투자 학습앱 주링고'), findsOneWidget);
  });

  testWidgets('저장된 로그인 정보가 있으면 홈 화면으로 시작한다', (tester) async {
    SharedPreferences.setMockInitialValues({
      'auth.user.v1': jsonEncode({
        'id': '1',
        'email': 'mock@email.com',
        'name': 'Mock User',
        'loginProvider': 'google',
        'joinDate': DateTime(2024, 1, 15).toIso8601String(),
      }),
    });
    final prefs = await SharedPreferences.getInstance();

    await _pumpApp(tester, prefs);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    // 하단 탭이 렌더링되었는지 확인
    expect(find.text('컨텐츠'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);
  });

  testWidgets('로그아웃하면 다시 로그인 화면으로 돌아온다', (tester) async {
    SharedPreferences.setMockInitialValues({
      'auth.user.v1': jsonEncode({
        'id': '1',
        'email': 'mock@email.com',
        'name': 'Mock User',
        'loginProvider': 'google',
        'joinDate': DateTime(2024, 1, 15).toIso8601String(),
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthRepository(prefs);

    await tester.pumpWidget(
      MyApp(auth: auth, progress: ProgressRepository(prefs)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomeScreen), findsOneWidget);

    await auth.logout();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
