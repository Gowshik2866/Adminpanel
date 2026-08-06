import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/auth_provider.dart';
import 'package:sample_app/screen/auth_screen.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/app_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const AppShell();
        }
        return const AuthScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Text(
            'Authentication Error: $error',
            style: const TextStyle(color: AppTheme.danger),
          ),
        ),
      ),
    );
  }
}
