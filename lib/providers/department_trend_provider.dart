import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/providers/attendance_provider.dart';
import 'package:sample_app/providers/staff_provider.dart';

enum TrendPeriod { today, week, month }

class DepartmentTrendArgs {
  final String department;
  final TrendPeriod period;

  const DepartmentTrendArgs({required this.department, required this.period});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentTrendArgs &&
          runtimeType == other.runtimeType &&
          department == other.department &&
          period == other.period;

  @override
  int get hashCode => department.hashCode ^ period.hashCode;
}

final departmentTrendProvider =
    Provider.family<List<double>, DepartmentTrendArgs>((ref, args) {
      final allStaff = ref.watch(staffProvider);
      final deptStaff = allStaff
          .where((s) => s.dept == args.department)
          .toList();

      if (deptStaff.isEmpty) return [];

      final allAttendance = ref.watch(attendanceProvider);
      final deptStaffIds = deptStaff.map((s) => s.id).toSet();

      final now = DateTime.now();
      final normalizedToday = DateTime(now.year, now.month, now.day);

      int daysToCompute;
      switch (args.period) {
        case TrendPeriod.today:
          daysToCompute = 1;
          break;
        case TrendPeriod.week:
          daysToCompute = 7;
          break;
        case TrendPeriod.month:
          daysToCompute = 30;
          break;
      }

      List<double> trends = [];

      for (int i = daysToCompute - 1; i >= 0; i--) {
        final targetDate = normalizedToday.subtract(Duration(days: i));

        int presentCount = 0;
        int totalCount = deptStaff.length;

        for (final staffId in deptStaffIds) {
          final record = allAttendance
              .where(
                (r) =>
                    r.staffId == staffId &&
                    r.date.year == targetDate.year &&
                    r.date.month == targetDate.month &&
                    r.date.day == targetDate.day,
              )
              .lastOrNull;

          if (record != null && record.status == AttendanceStatus.present) {
            presentCount++;
          }
        }

        double percent = (presentCount / totalCount) * 100.0;
        trends.add(percent);
      }

      if (trends.length == 1) {
        trends = [trends.first, trends.first];
      }

      return trends;
    });
