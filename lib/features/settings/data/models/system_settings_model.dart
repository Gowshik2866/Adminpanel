import 'package:sample_app/core/firestore/firestore_extensions.dart';
import 'package:sample_app/features/settings/domain/entities/system_settings.dart';

class SystemSettingsModel extends SystemSettings {
  const SystemSettingsModel({
    required super.workOnSaturdays,
    required super.officeStartTime,
    required super.officeEndTime,
    required super.maxSickLeaves,
    required super.maxCasualLeaves,
    required super.maxAnnualLeaves,
    super.isDarkMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'workOnSaturdays': workOnSaturdays,
      'officeStartTime': officeStartTime,
      'officeEndTime': officeEndTime,
      'maxSickLeaves': maxSickLeaves,
      'maxCasualLeaves': maxCasualLeaves,
      'maxAnnualLeaves': maxAnnualLeaves,
      'isDarkMode': isDarkMode,
    };
  }

  factory SystemSettingsModel.fromMap(Map<String, dynamic> map) {
    return SystemSettingsModel(
      workOnSaturdays: map.safeBool('workOnSaturdays', defaultValue: false),
      officeStartTime: map.safeString('officeStartTime', defaultValue: '09:00 AM'),
      officeEndTime: map.safeString('officeEndTime', defaultValue: '05:00 PM'),
      maxSickLeaves: map.safeInt('maxSickLeaves', defaultValue: 12),
      maxCasualLeaves: map.safeInt('maxCasualLeaves', defaultValue: 12),
      maxAnnualLeaves: map.safeInt('maxAnnualLeaves', defaultValue: 15),
      isDarkMode: map.safeBool('isDarkMode', defaultValue: false),
    );
  }

  factory SystemSettingsModel.fromEntity(SystemSettings entity) {
    return SystemSettingsModel(
      workOnSaturdays: entity.workOnSaturdays,
      officeStartTime: entity.officeStartTime,
      officeEndTime: entity.officeEndTime,
      maxSickLeaves: entity.maxSickLeaves,
      maxCasualLeaves: entity.maxCasualLeaves,
      maxAnnualLeaves: entity.maxAnnualLeaves,
      isDarkMode: entity.isDarkMode,
    );
  }
}
