import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/user.dart';
import 'package:sample_app/core/enums.dart';

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier()
    : super(
        User(
          id: 'ADM-001',
          name: 'Sarah Connor',
          email: 'admin@college.edu',
          role: Role.admin,
          lastLogin: DateTime.now(),
        ),
      );

  void login(User user) {
    state = user;
  }

  void logout() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
