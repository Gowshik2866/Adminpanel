import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/features/leave/domain/entities/holiday.dart';
import 'package:sample_app/features/leave/presentation/providers/leave_provider.dart';
import 'package:sample_app/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:sample_app/features/staff/presentation/providers/staff_provider.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/features/attendance/domain/entities/attendance.dart';

final holidayStreamProvider = StreamProvider<List<Holiday>>((ref) {
  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getHolidaysStream();
});

class HolidayController {
  final Ref _ref;

  HolidayController(this._ref);

  Future<void> addHoliday(
    String title,
    String description,
    DateTime startDate,
    DateTime endDate,
    String department,
  ) {
    final holiday = Holiday(
      id: '', // Firestore generates this
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      department: department,
    );
    return _ref.read(leaveRepositoryProvider).addHoliday(holiday);
  }

  Future<void> updateHoliday(Holiday holiday) {
    return _ref.read(leaveRepositoryProvider).addHoliday(holiday);
  }

  Future<void> deleteHoliday(String id) {
    return _ref.read(leaveRepositoryProvider).deleteHoliday(id);
  }

  bool isHoliday(DateTime date, String department) {
    final holidays = _ref.read(holidayProvider);
    return holidays.any((h) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final startOnly = DateTime(
        h.startDate.year,
        h.startDate.month,
        h.startDate.day,
      );
      final endOnly = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);

      final isDateMatch =
          dateOnly.isAtSameMomentAs(startOnly) ||
          dateOnly.isAtSameMomentAs(endOnly) ||
          (dateOnly.isAfter(startOnly) && dateOnly.isBefore(endOnly));

      return isDateMatch &&
          (h.department == 'All' || h.department == department);
    });
  }

  bool preventLeaveSubmission(DateTime date, String department) {
    return isHoliday(date, department);
  }
}

final holidayControllerProvider = Provider<HolidayController>((ref) {
  return HolidayController(ref);
});

// Backward compatibility provider for UI and attendance
final holidayProvider = Provider<List<Holiday>>((ref) {
  final asyncHolidays = ref.watch(holidayStreamProvider);
  return asyncHolidays.value ?? [];
});

final attendanceWithHolidayProvider = Provider<List<AttendanceRecord>>((ref) {
  final attendance = ref.watch(attendanceProvider);
  final holidayController = ref.watch(holidayControllerProvider);
  final staffList = ref.watch(staffProvider);

  return attendance.map((record) {
    final staff = staffList.where((s) => s.id == record.staffId).firstOrNull;
    if (staff != null && holidayController.isHoliday(record.date, staff.dept)) {
      return record.copyWith(status: AttendanceStatus.holiday);
    }
    return record;
  }).toList();
});

final todaysAttendanceWithHolidayProvider = Provider<List<AttendanceRecord>>((ref) {
  final records = ref.watch(attendanceWithHolidayProvider);
  final today = DateTime.now();
  return records
      .where(
        (r) =>
            r.date.year == today.year &&
            r.date.month == today.month &&
            r.date.day == today.day,
      )
      .toList();
});

final dashboardHolidayCountProvider = Provider<int>((ref) {
  final records = ref.watch(todaysAttendanceWithHolidayProvider);
  return records.where((r) => r.status == AttendanceStatus.holiday).length;
});
