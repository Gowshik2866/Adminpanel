import 'package:sample_app/features/settings/domain/entities/system_settings.dart';

abstract class SettingsRepository {
  Stream<SystemSettings> getSettingsStream();
  Future<void> updateSettings(SystemSettings settings);
}
