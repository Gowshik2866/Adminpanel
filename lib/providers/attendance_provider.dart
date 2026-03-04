import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/attendance.dart';
import 'package:sample_app/data/mock_data.dart';
import 'package:uuid/uuid.dart';

class AttendanceNotifier extends StateNotifier<List<AttendanceRecord>> {
  final _uuid = const Uuid();

  AttendanceNotifier() : super(MockData.initialAttendance);

  void markAttendance(String staffId, DateTime date, AttendanceStatus status) {
    bool exists = false;
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final updatedState = state.map((record) {
      if (record.staffId == staffId &&
          record.date.year == normalizedDate.year &&
          record.date.month == normalizedDate.month &&
          record.date.day == normalizedDate.day) {
        exists = true;
        return record.copyWith(status: status);
      }
      return record;
    }).toList();

    if (!exists) {
      updatedState.add(
        AttendanceRecord(
          id: _uuid.v4(),
          staffId: staffId,
          date: normalizedDate,
          status: status,
        ),
      );
    }

    state = updatedState;
  }

  void markLeaveForRange(String staffId, DateTime startDate, DateTime endDate) {
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.compareTo(end) <= 0) {
      // Skip weekends implicitly if required, but standard approach is to mark all
      markAttendance(staffId, current, AttendanceStatus.leave);
      current = current.add(const Duration(days: 1));
    }
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, List<AttendanceRecord>>((ref) {
      return AttendanceNotifier();
    });

// A derived provider to get today's attendance records easily
final todaysAttendanceProvider = Provider<List<AttendanceRecord>>((ref) {
  final records = ref.watch(attendanceProvider);
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
