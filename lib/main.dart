import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sample_app/firebase_options.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/models/system_settings.dart';
import 'package:sample_app/widgets/auth_gate.dart';
import 'package:sample_app/providers/settings_provider.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    developer.log(
      'Flutter Error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runApp(const ProviderScope(child: FirebaseInitializer()));
}

class FirebaseInitializer extends StatefulWidget {
  const FirebaseInitializer({super.key});

  @override
  State<FirebaseInitializer> createState() => _FirebaseInitializerState();
}

class _FirebaseInitializerState extends State<FirebaseInitializer> {
  late Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Failed to initialize Firebase: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return const StaffAdminApp();
        }

        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

class StaffAdminApp extends ConsumerWidget {
  const StaffAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings =
        settingsAsync.value ??
        const SystemSettings(
          workOnSaturdays: false,
          officeStartTime: '09:00 AM',
          officeEndTime: '05:00 PM',
          maxSickLeaves: 12,
          maxCasualLeaves: 12,
          maxAnnualLeaves: 15,
        );

    return MaterialApp(
      title: 'College Staff Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthGate(),
    );
  }
}
