import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:sample_app/models/holiday.dart';
import 'package:sample_app/providers/attendance_provider.dart';
import 'package:sample_app/providers/staff_provider.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/attendance.dart';

class HolidayNotifier extends StateNotifier<List<Holiday>> {
  final _uuid = const Uuid();

  HolidayNotifier()
    : super([
        Holiday(
          id: 'h-1',
          title: 'New Year',
          description: 'Happy New Year!',
          date: DateTime(DateTime.now().year, 1, 1),
          department: 'All',
        ),
        Holiday(
          id: 'h-2',
          title: 'Today Holiday',
          description: 'A mock holiday for today',
          date: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
          department: 'All',
        ),
      ]);

  void addHoliday(
    String title,
    String description,
    DateTime date,
    String department,
  ) {
    state = [
      ...state,
      Holiday(
        id: _uuid.v4(),
        title: title,
        description: description,
        date: date,
        department: department,
      ),
    ];
  }

  void updateHoliday(Holiday holiday) {
    state = [
      for (final h in state)
        if (h.id == holiday.id) holiday else h,
    ];
  }

  void deleteHoliday(String id) {
    state = state.where((h) => h.id != id).toList();
  }

  bool isHoliday(DateTime date, String department) {
    return state.any(
      (h) =>
          h.date.year == date.year &&
          h.date.month == date.month &&
          h.date.day == date.day &&
          (h.department == 'All' || h.department == department),
    );
  }

  // Called by other modules to optionally prevent leave
  bool preventLeaveSubmission(DateTime date, String department) {
    return isHoliday(date, department);
  }
}

final holidayProvider = StateNotifierProvider<HolidayNotifier, List<Holiday>>((
  ref,
) {
  return HolidayNotifier();
});

final attendanceWithHolidayProvider = Provider<List<AttendanceRecord>>((ref) {
  final attendance = ref.watch(attendanceProvider);
  final holidayNotifier = ref.watch(holidayProvider.notifier);
  final staffList = ref.watch(
    staffProvider,
  ); // to get department for each staff

  return attendance.map((record) {
    final staff = staffList.where((s) => s.id == record.staffId).firstOrNull;
    if (staff != null && holidayNotifier.isHoliday(record.date, staff.dept)) {
      return record.copyWith(status: AttendanceStatus.holiday);
    }
    return record;
  }).toList();
});

final todaysAttendanceWithHolidayProvider = Provider<List<AttendanceRecord>>((
  ref,
) {
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
