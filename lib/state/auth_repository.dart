import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

/// 로그인 상태를 보관하고 기기에 영속화합니다.
///
/// 현재는 목 구현입니다. 실제 OAuth 연동 시 [login]의 내부만
/// 교체하면 나머지 화면은 그대로 동작합니다.
class AuthRepository extends ChangeNotifier {
  static const _userKey = 'auth.user.v1';

  final SharedPreferences _prefs;
  User? _currentUser;

  AuthRepository(this._prefs) {
    _restore();
  }

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// 소셜 로그인. 성공 시 사용자 정보를 반환하고 기기에 저장합니다.
  Future<User?> login(String provider) async {
    // 네트워크 지연을 흉내 냅니다. 실제 연동 시 이 자리에 OAuth 호출이 들어갑니다.
    await Future.delayed(const Duration(seconds: 1));

    final user = User(
      id: '1',
      email: 'mock@email.com',
      name: 'Mock User',
      loginProvider: provider,
      joinDate: DateTime(2024, 1, 15),
    );
    _currentUser = user;
    notifyListeners();
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
    await _prefs.remove(_userKey);
  }

  void _restore() {
    final raw = _prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return;
    try {
      _currentUser =
          User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // 저장 형식이 깨진 경우 로그아웃 상태로 시작합니다.
      _currentUser = null;
    }
  }
}
