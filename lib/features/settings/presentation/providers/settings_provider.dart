import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/providers.dart';
import 'package:sample_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:sample_app/features/settings/data/sources/settings_remote_data_source.dart';
import 'package:sample_app/features/settings/domain/entities/system_settings.dart';
import 'package:sample_app/features/settings/domain/repositories/settings_repository.dart';

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SettingsRemoteDataSourceImpl(firestoreService);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource: remoteDataSource);
});

final settingsStreamProvider = StreamProvider<SystemSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getSettingsStream();
});

class SettingsController {
  final Ref _ref;
  final SettingsRepository _repository;

  SettingsController(this._ref, this._repository);

  Future<void> updateSettings(SystemSettings newSettings) {
    return _repository.updateSettings(newSettings);
  }

  Future<void> toggleSaturdayWork(bool workOnSaturdays) async {
    final currentSettings = _ref.read(settingsProvider);
    await _repository.updateSettings(currentSettings.copyWith(workOnSaturdays: workOnSaturdays));
  }

  Future<void> toggleTheme(bool isDark) async {
    final currentSettings = _ref.read(settingsProvider);
    await _repository.updateSettings(currentSettings.copyWith(isDarkMode: isDark));
  }
}

final settingsControllerProvider = Provider<SettingsController>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsController(ref, repository);
});

// Backward compatible provider for UI
final settingsProvider = Provider<SystemSettings>((ref) {
  final asyncSettings = ref.watch(settingsStreamProvider);
  return asyncSettings.value ?? const SystemSettings(
    workOnSaturdays: false,
    officeStartTime: '09:00 AM',
    officeEndTime: '05:00 PM',
    maxSickLeaves: 12,
    maxCasualLeaves: 12,
    maxAnnualLeaves: 15,
  );
});
