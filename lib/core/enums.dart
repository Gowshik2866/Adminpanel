// lib/core/enums.dart

enum LeaveType { sick, casual, annual, od }

enum LeaveStatus { pending, approved, rejected }

enum AttendanceStatus { present, absent, leave }

enum EmploymentType { fullTime, partTime, intern }

enum StaffStatus { active, inactive }

enum Role {
  professor,
  asstProf,
  hod,
  labInstructor,
  uiUxDesigner,
  srDeveloper,
  marketing,
  admin,
  other,
}

// Helper methods for displaying Enums
extension LeaveTypeExt on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.casual:
        return 'Casual Leave';
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.od:
        return 'Seminar OD';
    }
  }
}

extension LeaveStatusExt on LeaveStatus {
  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }
}

extension AttendanceStatusExt on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }
}

extension StaffStatusExt on StaffStatus {
  String get displayName {
    switch (this) {
      case StaffStatus.active:
        return 'Active';
      case StaffStatus.inactive:
        return 'Inactive';
    }
  }
}

extension EmploymentTypeExt on EmploymentType {
  String get displayName {
    switch (this) {
      case EmploymentType.fullTime:
        return 'Full-time';
      case EmploymentType.partTime:
        return 'Part-time';
      case EmploymentType.intern:
        return 'Intern';
    }
  }
}
