import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;

  // Mock authentication
  Future<User?> login(String email, String password, {String provider = 'google'}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful login
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: '1',
        email: email,
        name: 'Mock User',
        loginProvider: provider,
        joinDate: DateTime(2024, 1, 15), // Mock join date
      );
      return _currentUser;
    }
    return null;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  User? getCurrentUser() {
    return _currentUser;
  }

  Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }
}