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

  User copyWith({
    String? id,
    String? name,
    String? email,
    Role? role,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
