import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/providers/attendance_provider.dart';
import 'package:sample_app/providers/staff_provider.dart';

class DepartmentMonthlyTrend {
  final String department;
  final List<double> dailyPercentages;

  DepartmentMonthlyTrend({
    required this.department,
    required this.dailyPercentages,
  });
}

final monthlyDepartmentTrendProvider = Provider<List<DepartmentMonthlyTrend>>((
  ref,
) {
  final allStaff = ref.watch(staffProvider);
  final allAttendance = ref.watch(attendanceProvider);

  final uniqueDepts = allStaff.map((s) => s.dept).toSet().toList();

  final now = DateTime.now();
  final currentDay = now.day;

  // Find total days in current month up to today
  final daysToCompute = currentDay;

  List<DepartmentMonthlyTrend> trends = [];

  for (final dept in uniqueDepts) {
    final deptStaff = allStaff.where((s) => s.dept == dept).toList();
    if (deptStaff.isEmpty) continue;

    final deptStaffIds = deptStaff.map((s) => s.id).toSet();
    final totalStaffCount = deptStaff.length;

    List<double> dailyPercents = [];

    for (int day = 1; day <= daysToCompute; day++) {
      int presentCount = 0;

      for (final staffId in deptStaffIds) {
        final record = allAttendance
            .where(
              (r) =>
                  r.staffId == staffId &&
                  r.date.year == now.year &&
                  r.date.month == now.month &&
                  r.date.day == day,
            )
            .lastOrNull;

        if (record != null && record.status == AttendanceStatus.present) {
          presentCount++;
        }
      }

      double percent = (presentCount / totalStaffCount) * 100.0;
      dailyPercents.add(percent);
    }

    // Ensure the chart has at least two points to draw a line initially
    if (dailyPercents.isEmpty) {
      dailyPercents = [0, 0];
    } else if (dailyPercents.length == 1) {
      dailyPercents = [dailyPercents.first, dailyPercents.first];
    }

    trends.add(
      DepartmentMonthlyTrend(department: dept, dailyPercentages: dailyPercents),
    );
  }

  return trends;
});
