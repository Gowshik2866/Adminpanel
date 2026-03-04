class SystemSettings {
  final bool workOnSaturdays;
  final String officeStartTime; // e.g. "09:00 AM"
  final String officeEndTime; // e.g. "05:00 PM"
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
}
