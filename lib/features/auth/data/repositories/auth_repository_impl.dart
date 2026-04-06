import 'package:sample_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sample_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/features/auth/data/models/user_model.dart';
import 'package:sample_app/core/enums.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User?> login(String email, String password) async {
    final credentials = await remoteDataSource.login(email, password);
    if (credentials.user != null) {
      return getCurrentUser(credentials.user!.uid);
    }
    return null;
  }

  @override
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
    required Role role,
  }) async {
    final credentials = await remoteDataSource.signUp(email, password);
    if (credentials.user != null) {
      final newUser = UserModel(
        id: credentials.user!.uid,
        name: name,
        email: email.trim(),
        role: role,
        lastLogin: DateTime.now(),
      );
      await remoteDataSource.saveUserData(newUser, department);
      return newUser;
    }
    return null;
  }

  @override
  Future<void> logout() => remoteDataSource.logout();

  @override
  Future<User?> getCurrentUser(String uid) async {
    final userData = await remoteDataSource.getUserData(uid);
    if (userData != null) {
      return UserModel.fromMap(userData);
    }
    return null;
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return getCurrentUser(firebaseUser.uid);
    });
  }
}
