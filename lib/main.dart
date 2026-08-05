import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sample_app/features/auth/presentation/screens/login_screen.dart';
import 'package:sample_app/widgets/app_shell.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sample_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const StaffAdminApp(),
    ),
  );
}

class StaffAdminApp extends ConsumerWidget {
  const StaffAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'College Staff Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: user == null ? const LoginScreen() : const AppShell(),
    );
  }
}
