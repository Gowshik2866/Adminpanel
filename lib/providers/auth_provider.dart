import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/user.dart';
import 'package:sample_app/core/enums.dart';

// ─── Mock Credentials ─────────────────────────────────────────────────────────
// TODO: Replace _authenticate() body with an HTTP POST to your auth endpoint.
const _mockEmail = 'admin@attendance.com';
const _mockPassword = 'admin123';

// ─── Auth State Notifier ──────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null); // Start logged-out

  bool _loading = false;
  bool get isLoading => _loading;

  /// Returns an error string on failure, null on success.
  Future<String?> authenticate(String email, String password) async {
    _loading = true;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 900));

    _loading = false;

    final emailTrimmed = email.trim().toLowerCase();
    final passwordTrimmed = password.trim();

    // ── Mock check (swap this block for real API call) ────────────────────────
    if (emailTrimmed == _mockEmail && passwordTrimmed == _mockPassword) {
      state = User(
        id: 'ADM-001',
        name: 'Admin User',
        email: emailTrimmed,
        role: Role.admin,
        lastLogin: DateTime.now(),
      );
      return null; // success
    }

    return 'Invalid email or password. Please try again.';
  }

  void login(User user) => state = user;

  void logout() => state = null;
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
