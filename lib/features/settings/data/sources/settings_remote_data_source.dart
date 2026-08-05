import 'package:sample_app/core/firestore/firestore_constants.dart';
import 'package:sample_app/core/firestore/firestore_service.dart';
import 'package:sample_app/features/settings/data/models/system_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Stream<SystemSettingsModel> getSettingsStream();
  Future<void> updateSettings(SystemSettingsModel settings);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final FirestoreService _firestoreService;
  
  // Settings is typically a single document
  static const String _settingsDocId = 'global_settings';

  SettingsRemoteDataSourceImpl(this._firestoreService);

  @override
  Stream<SystemSettingsModel> getSettingsStream() {
    return _firestoreService.documentStream<SystemSettingsModel>(
      path: FirestoreConstants.settings,
      docId: _settingsDocId,
      builder: (data, documentId) {
        if (data == null || data.isEmpty) {
          // Return default settings if document doesn't exist
          return const SystemSettingsModel(
            workOnSaturdays: false,
            officeStartTime: '09:00 AM',
            officeEndTime: '05:00 PM',
            maxSickLeaves: 12,
            maxCasualLeaves: 12,
            maxAnnualLeaves: 15,
          );
        }
        return SystemSettingsModel.fromMap(data);
      },
    );
  }

  @override
  Future<void> updateSettings(SystemSettingsModel settings) {
    return _firestoreService.addDocument(
      path: FirestoreConstants.settings,
      data: settings.toMap(),
      docId: _settingsDocId,
    );
  }
}
