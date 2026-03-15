import 'package:sample_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/core/enums.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<User?> execute({
    required String email,
    required String password,
    required String name,
    required String department,
    required Role role,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      name: name,
      department: department,
      role: role,
    );
  }
}
