import 'package:sample_app/models/system_settings.dart';
import 'package:sample_app/data/remote/firestore_service.dart';

class SettingsRepository {
  final _service = FirestoreService.instance;
  final String _docPath = 'settings/system';

  Stream<SystemSettings> watchSettings() {
    return _service.documentStream<SystemSettings>(
      path: _docPath,
      builder: (doc) {
        if (!doc.exists) {
          return const SystemSettings(
            workOnSaturdays: false,
            officeStartTime: '09:00 AM',
            officeEndTime: '05:00 PM',
            maxSickLeaves: 12,
            maxCasualLeaves: 12,
            maxAnnualLeaves: 15,
          );
        }
        return SystemSettings.fromFirestore(doc);
      },
    );
  }

  Future<void> toggleTheme(SystemSettings current) async {
    await updateSettings(current.copyWith(isDarkMode: !current.isDarkMode));
  }

  Future<void> updateSettings(SystemSettings settings) async {
    await _service.setData(
      path: _docPath,
      data: settings.toFirestore(),
      merge: true,
    );
  }
}
