import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/system_settings.dart';
import 'package:sample_app/data/mock_data.dart';

class SettingsNotifier extends StateNotifier<SystemSettings> {
  SettingsNotifier() : super(MockData.defaultSettings);

  void updateSettings(SystemSettings newSettings) {
    state = newSettings;
  }

  void toggleSaturdayWork(bool workOnSaturdays) {
    state = state.copyWith(workOnSaturdays: workOnSaturdays);
  }

  void toggleTheme(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SystemSettings>((ref) {
      return SettingsNotifier();
    });
