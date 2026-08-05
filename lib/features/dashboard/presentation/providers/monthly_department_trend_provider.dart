import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/core/providers.dart';
import 'package:sample_app/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:sample_app/features/staff/presentation/providers/staff_provider.dart';

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

  final now = ref.watch(todayProvider);
  final currentDay = now.day;

  // Find total days in current month up to today
  final daysToCompute = currentDay;

  // Pre-compute attendance lookup map for O(1) access
  // Key: staffId_year_month_day
  final attendanceMap = <String, AttendanceStatus>{};
  for (final record in allAttendance) {
    final key =
        '${record.staffId}_${record.date.year}_${record.date.month}_${record.date.day}';
    attendanceMap[key] = record.status;
  }

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
        final key = '${staffId}_${now.year}_${now.month}_$day';
        final status = attendanceMap[key];

        if (status == AttendanceStatus.present) {
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
