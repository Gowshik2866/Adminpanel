import 'package:sample_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User?> execute(String email, String password) {
    return repository.login(email, password);
  }
}
