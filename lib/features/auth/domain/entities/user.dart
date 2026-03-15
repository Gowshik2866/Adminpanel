import 'package:sample_app/core/enums.dart';

class User {
  final String id;
  final String name;
  final String email;
  final Role role;
  final DateTime lastLogin;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: Role.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => Role.other,
      ),
      lastLogin: DateTime.tryParse(map['lastLogin'] ?? '') ?? DateTime.now(),
    );
  }
}
