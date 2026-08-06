import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/system_settings.dart';
import 'package:sample_app/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider = StreamProvider<SystemSettings>((ref) {
  return ref.read(settingsRepositoryProvider).watchSettings();
});
