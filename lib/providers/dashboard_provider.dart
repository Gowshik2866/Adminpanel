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

final dashboardMetricsProvider = Provider<AsyncValue<DashboardMetrics>>((ref) {
  final staffAsync = ref.watch(staffProvider);
  final attendanceAsync = ref.watch(attendanceProvider);
  final leaveAsync = ref.watch(leaveProvider);

  if (staffAsync.isLoading ||
      attendanceAsync.isLoading ||
      leaveAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (staffAsync.hasError) {
    return AsyncValue.error(staffAsync.error!, staffAsync.stackTrace!);
  }
  if (attendanceAsync.hasError) {
    return AsyncValue.error(
      attendanceAsync.error!,
      attendanceAsync.stackTrace!,
    );
  }
  if (leaveAsync.hasError) {
    return AsyncValue.error(leaveAsync.error!, leaveAsync.stackTrace!);
  }

  final allStaff = staffAsync.value ?? [];
  final activeStaff = allStaff
      .where((s) => s.status == StaffStatus.active)
      .toList();

  final allAttendance = attendanceAsync.value ?? [];
  final now = DateTime.now();
  final todaysAttendance = allAttendance
      .where(
        (a) =>
            a.date.year == now.year &&
            a.date.month == now.month &&
            a.date.day == now.day,
      )
      .toList();

  final allLeaves = leaveAsync.value ?? [];
  final pendingLeaves = allLeaves
      .where((l) => l.status == LeaveStatus.pending)
      .toList();

  int presentCount = 0;
  int absentCount = 0;

  Map<String, int> deptTotal = {};
  Map<String, int> deptPresent = {};

  for (final staff in activeStaff) {
    deptTotal[staff.dept] = (deptTotal[staff.dept] ?? 0) + 1;

    final recordIdx = todaysAttendance.indexWhere((r) => r.staffId == staff.id);

    if (recordIdx != -1) {
      if (todaysAttendance[recordIdx].status == AttendanceStatus.present) {
        presentCount++;
        deptPresent[staff.dept] = (deptPresent[staff.dept] ?? 0) + 1;
      } else {
        absentCount++;
        deptPresent[staff.dept] = deptPresent[staff.dept] ?? 0;
      }
    } else {
      // If no record, consider absent for metrics
      absentCount++;
      deptPresent[staff.dept] = deptPresent[staff.dept] ?? 0;
    }
  }

  Map<String, double> deptPercent = {};
  deptTotal.forEach((dept, total) {
    int present = deptPresent[dept] ?? 0;
    deptPercent[dept] = total > 0 ? (present / total) : 0.0;
  });

  return AsyncValue.data(
    DashboardMetrics(
      totalStaff: activeStaff.length,
      presentToday: presentCount,
      absentToday: absentCount,
      pendingLeaves: pendingLeaves.length,
      deptAttendancePercent: deptPercent,
    ),
  );
});
