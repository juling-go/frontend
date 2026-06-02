class User {
  final String id;
  final String email;
  final String name;
  final String loginProvider; // 'google' or 'kakao'
  final DateTime joinDate;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.loginProvider,
    required this.joinDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      loginProvider: json['loginProvider'] ?? 'google',
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'loginProvider': loginProvider,
      'joinDate': joinDate.toIso8601String(),
    };
  }
}