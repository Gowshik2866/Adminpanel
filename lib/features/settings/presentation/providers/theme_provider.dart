import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

class ThemeNotifier extends StateNotifier<bool> {
  final SharedPreferences prefs;

  ThemeNotifier(this.prefs) : super(prefs.getBool('isDarkMode') ?? false);

  void toggleTheme(bool isDark) {
    state = isDark;
    prefs.setBool('isDarkMode', isDark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
