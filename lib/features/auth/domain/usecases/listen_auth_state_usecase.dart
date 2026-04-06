import 'package:sample_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';

class ListenAuthStateUseCase {
  final AuthRepository repository;

  ListenAuthStateUseCase(this.repository);

  Stream<User?> execute() {
    return repository.authStateChanges;
  }
}
