import 'package:sample_app/features/settings/data/models/system_settings_model.dart';
import 'package:sample_app/features/settings/data/sources/settings_remote_data_source.dart';
import 'package:sample_app/features/settings/domain/entities/system_settings.dart';
import 'package:sample_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<SystemSettings> getSettingsStream() {
    return remoteDataSource.getSettingsStream();
  }

  @override
  Future<void> updateSettings(SystemSettings settings) {
    return remoteDataSource.updateSettings(SystemSettingsModel.fromEntity(settings));
  }
}
