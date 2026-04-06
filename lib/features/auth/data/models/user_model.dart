import 'package:sample_app/core/enums.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.lastLogin,
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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
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
