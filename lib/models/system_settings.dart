import 'package:cloud_firestore/cloud_firestore.dart';

class SystemSettings {
  final bool workOnSaturdays;
  final String officeStartTime;
  final String officeEndTime;
  final int maxSickLeaves;
  final int maxCasualLeaves;
  final int maxAnnualLeaves;
  final bool isDarkMode;

  const SystemSettings({
    required this.workOnSaturdays,
    required this.officeStartTime,
    required this.officeEndTime,
    required this.maxSickLeaves,
    required this.maxCasualLeaves,
    required this.maxAnnualLeaves,
    this.isDarkMode = false,
  });

  SystemSettings copyWith({
    bool? workOnSaturdays,
    String? officeStartTime,
    String? officeEndTime,
    int? maxSickLeaves,
    int? maxCasualLeaves,
    int? maxAnnualLeaves,
    bool? isDarkMode,
  }) {
    return SystemSettings(
      workOnSaturdays: workOnSaturdays ?? this.workOnSaturdays,
      officeStartTime: officeStartTime ?? this.officeStartTime,
      officeEndTime: officeEndTime ?? this.officeEndTime,
      maxSickLeaves: maxSickLeaves ?? this.maxSickLeaves,
      maxCasualLeaves: maxCasualLeaves ?? this.maxCasualLeaves,
      maxAnnualLeaves: maxAnnualLeaves ?? this.maxAnnualLeaves,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  Map<String, dynamic> toJson() {
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

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      workOnSaturdays: json['workOnSaturdays'] as bool? ?? false,
      officeStartTime: json['officeStartTime'] as String? ?? '09:00 AM',
      officeEndTime: json['officeEndTime'] as String? ?? '05:00 PM',
      maxSickLeaves: json['maxSickLeaves'] as int? ?? 12,
      maxCasualLeaves: json['maxCasualLeaves'] as int? ?? 12,
      maxAnnualLeaves: json['maxAnnualLeaves'] as int? ?? 15,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  factory SystemSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SystemSettings.fromJson(data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemSettings &&
          runtimeType == other.runtimeType &&
          workOnSaturdays == other.workOnSaturdays &&
          officeStartTime == other.officeStartTime &&
          officeEndTime == other.officeEndTime &&
          maxSickLeaves == other.maxSickLeaves &&
          maxCasualLeaves == other.maxCasualLeaves &&
          maxAnnualLeaves == other.maxAnnualLeaves &&
          isDarkMode == other.isDarkMode;

  @override
  int get hashCode =>
      workOnSaturdays.hashCode ^
      officeStartTime.hashCode ^
      officeEndTime.hashCode ^
      maxSickLeaves.hashCode ^
      maxCasualLeaves.hashCode ^
      maxAnnualLeaves.hashCode ^
      isDarkMode.hashCode;
}
