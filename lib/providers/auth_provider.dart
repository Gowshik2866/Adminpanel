import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/user.dart';
import 'package:sample_app/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.read(authRepositoryProvider).currentUser;
});
