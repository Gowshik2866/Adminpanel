import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/staff.dart';
import 'package:sample_app/models/attendance.dart';
import 'package:sample_app/models/leave_request.dart';
import 'package:sample_app/models/system_settings.dart';
import 'package:uuid/uuid.dart';

class MockData {
  static const _uuid = Uuid();

  // Settings
  static const SystemSettings defaultSettings = SystemSettings(
    workOnSaturdays: false,
    officeStartTime: '09:00 AM',
    officeEndTime: '05:00 PM',
    maxSickLeaves: 12,
    maxCasualLeaves: 12,
    maxAnnualLeaves: 15,
  );

  // Staff
  static final List<Staff> initialStaff = [
    Staff(
      id: 'F001',
      name: 'Dr. Alice Johnson',
      email: 'alice.j@engg.edu',
      phone: '123-456-7890',
      role: 'Professor',
      dept: 'CSE',
      employmentType: EmploymentType.fullTime,
      status: StaffStatus.active,
      joiningDate: DateTime(2018, 5, 20),
    ),
    Staff(
      id: 'F002',
      name: 'Prof. Bob Martin',
      email: 'bob.m@engg.edu',
      phone: '987-654-3210',
      role: 'Asst. Prof',
      dept: 'ECE',
      employmentType: EmploymentType.fullTime,
      status: StaffStatus.active,
      joiningDate: DateTime(2020, 8, 15),
    ),
    Staff(
      id: 'F003',
      name: 'Dr. Carol White',
      email: 'carol.w@engg.edu',
      phone: '555-123-4567',
      role: 'HOD',
      dept: 'MECH',
      employmentType: EmploymentType.fullTime,
      status: StaffStatus.active,
      joiningDate: DateTime(2015, 1, 10),
    ),
    Staff(
      id: 'F004',
      name: 'David Lee',
      email: 'david.l@engg.edu',
      phone: '111-222-3333',
      role: 'Lab Instructor',
      dept: 'IT',
      employmentType: EmploymentType.fullTime,
      status: StaffStatus.active,
      joiningDate: DateTime(2021, 3, 1),
    ),
    Staff(
      id: 'F005',
      name: 'Dr. Eva Chen',
      email: 'eva.c@engg.edu',
      phone: '444-555-6666',
      role: 'Professor',
      dept: 'AI&DS',
      employmentType: EmploymentType.partTime,
      status: StaffStatus.active,
      joiningDate: DateTime(2019, 11, 20),
    ),
    Staff(
      id: 'F006',
      name: 'Dr. Mark Smith',
      email: 'mark.s@engg.edu',
      phone: '777-888-9999',
      role: 'Professor',
      dept: 'CIVIL',
      employmentType: EmploymentType.fullTime,
      status: StaffStatus.inactive,
      joiningDate: DateTime(2017, 7, 7),
    ),
  ];

  static final List<AttendanceRecord> initialAttendance =
      generateInitialAttendance();

  static List<AttendanceRecord> generateInitialAttendance() {
    final List<AttendanceRecord> records = [];
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      // Skip weekends roughly (not using exact calendar logic here for simplicity but let's avoid typical weekends)
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }
      for (final staff in initialStaff) {
        // Give some random absences
        AttendanceStatus status = AttendanceStatus.present;
        if (date.day % 7 == 0 && staff.id == 'F002') {
          status = AttendanceStatus.absent;
        } else if (date.day % 14 == 0 && staff.id == 'F005') {
          status = AttendanceStatus.leave;
        }

        // Let's make today match the static list roughly.
        // Dr. Alice - Present
        // Prof. Bob - Absent
        // Dr. Eva - Absent
        if (i == 0) {
          if (staff.id == 'F002' || staff.id == 'F005') {
            status = AttendanceStatus.absent;
          } else {
            status = AttendanceStatus.present;
          }
        }

        records.add(
          AttendanceRecord(
            id: _uuid.v4(),
            staffId: staff.id,
            date: DateTime(date.year, date.month, date.day),
            status: status,
          ),
        );
      }
    }
    return records;
  }

  static final List<LeaveRequestModel> initialLeaveRequests = [
    LeaveRequestModel(
      id: _uuid.v4(),
      staff: initialStaff.firstWhere(
        (s) => s.id == 'F002',
        orElse: () => initialStaff.first,
      ),
      leaveType: LeaveType.sick,
      dateRange: 'Oct 24 – Oct 26',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      status: LeaveStatus.pending,
      reason: 'Fever and cold.',
    ),
    LeaveRequestModel(
      id: _uuid.v4(),
      staff: initialStaff.firstWhere(
        (s) => s.id == 'F005',
        orElse: () => initialStaff[4],
      ),
      leaveType: LeaveType.od,
      dateRange: 'Oct 28 (Full Day)',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      status: LeaveStatus.pending,
      reason: 'Attending AI Conference.',
    ),
    LeaveRequestModel(
      id: _uuid.v4(),
      staff: initialStaff.firstWhere(
        (s) => s.id == 'F001',
        orElse: () => initialStaff.first,
      ),
      leaveType: LeaveType.annual,
      dateRange: 'Nov 01 – Nov 05',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 5)),
      status: LeaveStatus.approved,
      reason: 'Family vacation.',
    ),
  ];
}
