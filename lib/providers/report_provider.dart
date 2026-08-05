import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/providers/staff_provider.dart';
import 'package:sample_app/providers/attendance_provider.dart';

class ReportMetrics {
  final double overallAttendancePercent;
  final int totalWorkingDays;
  final Map<String, double> staffAttendancePercent; // Staff ID -> Percent
  final Map<String, double> deptAttendancePercent; // Dept Name -> Percent

  const ReportMetrics({
    required this.overallAttendancePercent,
    required this.totalWorkingDays,
    required this.staffAttendancePercent,
    required this.deptAttendancePercent,
  });
}

final reportOverviewProvider = Provider<ReportMetrics>((ref) {
  final staffList = ref.watch(staffProvider);
  final allRecords = ref.watch(attendanceProvider);

  // Determine total mock working days by counting unique dates
  final uniqueDates = allRecords.map((r) => r.date).toSet();
  int totalDays = uniqueDates.length;
  if (totalDays == 0) {
    return const ReportMetrics(
      overallAttendancePercent: 0,
      totalWorkingDays: 0,
      staffAttendancePercent: {},
      deptAttendancePercent: {},
    );
  }

  int totalPresents = 0;
  Map<String, int> staffPresents = {};

  for (final record in allRecords) {
    if (record.status == AttendanceStatus.present) {
      totalPresents++;
      staffPresents[record.staffId] = (staffPresents[record.staffId] ?? 0) + 1;
    }
  }

  Map<String, double> staffPercent = {};
  Map<String, int> deptTotalExpected = {};
  Map<String, int> deptTotalPresent = {};

  for (final staff in staffList) {
    int present = staffPresents[staff.id] ?? 0;
    staffPercent[staff.id] = present / totalDays;

    deptTotalExpected[staff.dept] =
        (deptTotalExpected[staff.dept] ?? 0) + totalDays;
    deptTotalPresent[staff.dept] =
        (deptTotalPresent[staff.dept] ?? 0) + present;
  }

  Map<String, double> deptPercent = {};
  deptTotalExpected.forEach((dept, expected) {
    int present = deptTotalPresent[dept] ?? 0;
    deptPercent[dept] = expected > 0 ? present / expected : 0.0;
  });

  return ReportMetrics(
    overallAttendancePercent: (allRecords.isNotEmpty)
        ? (totalPresents / allRecords.length)
        : 0.0,
    totalWorkingDays: totalDays,
    staffAttendancePercent: staffPercent,
    deptAttendancePercent: deptPercent,
  );
});
