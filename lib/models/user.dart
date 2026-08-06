import 'package:cloud_firestore/cloud_firestore.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: Role.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => Role.other,
      ),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: Role.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => Role.other,
      ),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          role == other.role &&
          lastLogin == other.lastLogin;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      role.hashCode ^
      lastLogin.hashCode;
}
