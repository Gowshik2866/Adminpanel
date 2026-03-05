import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/app_shell.dart';
import 'package:sample_app/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    return MaterialApp(
      title: 'College Staff Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AppShell(),
    );
  }
}

// -------------------------------------------------------------
// REUSABLE UI COMPONENTS (States & Interactions)
// -------------------------------------------------------------

// -------------------------------------------------------------
// HEADER & NAVIGATION
// -------------------------------------------------------------

// -------------------------------------------------------------
// DASHBOARD SCREEN
// -------------------------------------------------------------

// -------------------------------------------------------------
// USERS SCREEN (STAFF DIRECTORY) WITH SEARCH STATE
// -------------------------------------------------------------

//-------------------------------------------------------------
// ATTENDANCE REQUEST
//--------------------------------------------------------------

// -------------------------------------------------------------
// REPORTS SCREEN WITH LOADING STATE
// -------------------------------------------------------------

// -------------------------------------------------------------
// SETTINGS SCREEN (Redesigned Hierarchy)
// -------------------------------------------------------------
