import 'dart:math';
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

  static final _random = Random(42);

  // Staff
  static final List<Staff> initialStaff = _generateStaff();

  static List<Staff> _generateStaff() {
    final List<Staff> staffList = [];
    final Map<String, int> deptSizes = {
      'CSE': 42,
      'AI&DS': 35,
      'MECH': 28,
      'ECE': 31,
      'MBA': 22,
    };
    int idCounter = 1;

    deptSizes.forEach((dept, count) {
      for (int i = 0; i < count; i++) {
        final id = 'F${idCounter.toString().padLeft(3, '0')}';
        staffList.add(
          Staff(
            id: id,
            name: 'Staff $id',
            email: 'staff$id@engg.edu',
            phone: '555-000-${idCounter.toString().padLeft(4, '0')}',
            role: i == 0 ? 'HOD' : (i < 5 ? 'Professor' : 'Asst. Prof'),
            dept: dept,
            employmentType: EmploymentType.fullTime,
            status: StaffStatus.active,
            joiningDate: DateTime(
              2015 + _random.nextInt(8),
              _random.nextInt(12) + 1,
              _random.nextInt(28) + 1,
            ),
          ),
        );
        idCounter++;
      }
    });
    return staffList;
  }

  static final List<AttendanceRecord> initialAttendance =
      _generateInitialAttendance();

  static List<AttendanceRecord> _generateInitialAttendance() {
    final List<AttendanceRecord> records = [];
    final today = DateTime.now();

    double getDeptBase(String dept) {
      if (dept == 'CSE' || dept == 'AI&DS') return 90.0;
      if (dept == 'ECE') return 86.0;
      if (dept == 'MECH') return 78.0;
      if (dept == 'MBA') return 80.0;
      return 85.0;
    }

    double getDeptVolatility(String dept) {
      if (dept == 'CSE' || dept == 'AI&DS') return 5.5;
      if (dept == 'ECE') return 6.0;
      if (dept == 'MECH') return 7.5;
      if (dept == 'MBA') return 18.0;
      return 10.0;
    }

    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final isWeekend =
          (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday);
      final improvementFactor =
          ((29 - i) / 29) * 4.0; // Gradual improvement toward 'today'

      for (final s in initialStaff) {
        double base = getDeptBase(s.dept);
        double vol = getDeptVolatility(s.dept);
        double targetPercent = base + (_random.nextDouble() * vol * 2 - vol);

        targetPercent += improvementFactor;

        if (isWeekend) targetPercent -= 8.0; // slight dip on weekends
        if (i == 14 || i == 24) targetPercent -= 12.0; // noticeable low days

        if (targetPercent > 100) targetPercent = 100;
        if (targetPercent < 0) targetPercent = 0;

        double chance = _random.nextDouble() * 100;
        AttendanceStatus status;

        if (chance <= targetPercent) {
          status = AttendanceStatus.present;
        } else {
          double rem = _random.nextDouble();
          if (rem > 0.6) {
            status = AttendanceStatus.leave;
          } else {
            status = AttendanceStatus.absent;
          }
        }

        records.add(
          AttendanceRecord(
            id: _uuid.v4(),
            staffId: s.id,
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
