import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/providers.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:sample_app/features/staff/presentation/providers/staff_provider.dart';

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

      final now = ref.watch(todayProvider);
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

      // Index attendance records by date key -> set of present department staff IDs
      final Map<String, Set<String>> presentStaffByDate = {};
      for (final r in allAttendance) {
        if (r.status == AttendanceStatus.present && deptStaffIds.contains(r.staffId)) {
          final dateKey = '${r.date.year}-${r.date.month}-${r.date.day}';
          (presentStaffByDate[dateKey] ??= {}).add(r.staffId);
        }
      }

      List<double> trends = [];

      for (int i = daysToCompute - 1; i >= 0; i--) {
        final targetDate = normalizedToday.subtract(Duration(days: i));
        final dateKey = '${targetDate.year}-${targetDate.month}-${targetDate.day}';

        final presentCount = presentStaffByDate[dateKey]?.length ?? 0;
        final totalCount = deptStaff.length;

        double percent = totalCount > 0 ? (presentCount / totalCount) * 100.0 : 0.0;
        trends.add(percent);
      }

      if (trends.length == 1) {
        trends = [trends.first, trends.first];
      }

      return trends;
    });
