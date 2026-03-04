import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/providers/staff_provider.dart';
import 'package:sample_app/providers/attendance_provider.dart';
import 'package:sample_app/providers/leave_provider.dart';

class DashboardMetrics {
  final int totalStaff;
  final int presentToday;
  final int absentToday;
  final int pendingLeaves;
  final Map<String, double> deptAttendancePercent;

  const DashboardMetrics({
    required this.totalStaff,
    required this.presentToday,
    required this.absentToday,
    required this.pendingLeaves,
    required this.deptAttendancePercent,
  });
}

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final activeStaff = ref.watch(activeStaffProvider);
  final todaysAttendance = ref.watch(todaysAttendanceProvider);
  final pendingLeaves = ref.watch(pendingLeavesProvider);

  int presentCount = 0;
  int absentCount = 0;

  Map<String, int> deptTotal = {};
  Map<String, int> deptPresent = {};

  for (final staff in activeStaff) {
    deptTotal[staff.dept] = (deptTotal[staff.dept] ?? 0) + 1;

    final record = todaysAttendance.firstWhere(
      (r) => r.staffId == staff.id,
      orElse: () => throw StateError('No attendance record'),
      // In a real app we might not throw here, but mock data generates for all
    );

    if (record.status == AttendanceStatus.present) {
      presentCount++;
      deptPresent[staff.dept] = (deptPresent[staff.dept] ?? 0) + 1;
    } else {
      absentCount++;
      deptPresent[staff.dept] = deptPresent[staff.dept] ?? 0;
    }
  }

  Map<String, double> deptPercent = {};
  deptTotal.forEach((dept, total) {
    int present = deptPresent[dept] ?? 0;
    deptPercent[dept] = total > 0 ? (present / total) : 0.0;
  });

  return DashboardMetrics(
    totalStaff: activeStaff.length,
    presentToday: presentCount,
    absentToday: absentCount,
    pendingLeaves: pendingLeaves.length,
    deptAttendancePercent: deptPercent,
  );
});
