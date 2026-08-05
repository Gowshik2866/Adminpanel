import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sample_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sample_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/core/enums.dart';

// ─── Dependency Injection Providers ─────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final authLoadingProvider = StateProvider<bool>((ref) => false);

// ─── Auth Notifier (State Management) ───────────────────────────────────────

class AuthNotifier extends StateNotifier<User?> {
  final AuthRepository repository;
  final Ref ref;
  StreamSubscription<User?>? _subscription;

  AuthNotifier(this.repository, this.ref) : super(null) {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _subscription = repository.authStateChanges.listen((user) {
      state = user;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    ref.read(authLoadingProvider.notifier).state = value;
  }

  bool get isLoading => ref.read(authLoadingProvider);

  Future<String?> login(String email, String password) async {
    try {
      _setLoading(true);
      await repository.login(email, password);
      _setLoading(false);
      return null;
    } catch (e) {
      _setLoading(false);
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
    required Role role,
  }) async {
    try {
      _setLoading(true);
      await repository.signUp(
        email: email,
        password: password,
        name: name,
        department: department,
        role: role,
      );
      _setLoading(false);
      return null;
    } catch (e) {
      _setLoading(false);
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> logout() async {
    await repository.logout();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});
