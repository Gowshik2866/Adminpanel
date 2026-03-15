import 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/core/enums.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
    required Role role,
  });
  Future<void> logout();
  Stream<User?> get authStateChanges;
  Future<User?> getCurrentUser(String uid);
}
