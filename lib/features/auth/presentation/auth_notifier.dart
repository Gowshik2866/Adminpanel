import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sample_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sample_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sample_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:sample_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sample_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/core/enums.dart';

// ─── Dependency Injection ───────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// ─── Auth Notifier ──────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<User?> {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _repository;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository repository,
  })  : _loginUseCase = loginUseCase,
        _signUpUseCase = signUpUseCase,
        _logoutUseCase = logoutUseCase,
        _repository = repository,
        super(null) {
    _listenToAuthState();
  }

  bool _loading = false;
  bool get isLoading => _loading;

  void _listenToAuthState() {
    _repository.authStateChanges.listen((user) {
      state = user;
    });
  }

  Future<String?> login(String email, String password) async {
    try {
      _loading = true;
      await _loginUseCase.execute(email, password);
      // state is updated via authStateChanges listener
      _loading = false;
      return null;
    } catch (e) {
      _loading = false;
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
      _loading = true;
      await _signUpUseCase.execute(
        email: email,
        password: password,
        name: name,
        department: department,
        role: role,
      );
      _loading = false;
      return null;
    } catch (e) {
      _loading = false;
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> logout() async {
    await _logoutUseCase.execute();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    repository: ref.watch(authRepositoryProvider),
  );
});
