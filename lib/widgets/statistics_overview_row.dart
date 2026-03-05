import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/screen/users_screen.dart';
import 'package:sample_app/screens/attendance_analytics_screen.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/overview_stat_card.dart';
import 'package:sample_app/providers/dashboard_provider.dart';
import 'package:sample_app/providers/holiday_provider.dart';

class StatisticsOverviewRow extends ConsumerWidget {
  const StatisticsOverviewRow({super.key});

  // ── Navigation helpers ──────────────────────────────────────────────────────

  void _goToStaffDirectory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UsersScreen()));
  }

  void _goToAnalytics(BuildContext context, AttendanceFilter filter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceAnalyticsScreen(initialFilter: filter),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    final holidayCount = ref.watch(dashboardHolidayCountProvider);

    return Row(
      children: [
        // ── Total Staff → Staff Directory ───────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _goToStaffDirectory(context),
            child: OverviewStatCard(
              label: 'Total Staff',
              value: '${metrics.totalStaff}',
              delta: '',
              positive: true,
              icon: Icons.groups_rounded,
              bg: Theme.of(context).colorScheme.primaryContainer,
              ic: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // ── Present Today → Analytics (Present filter) ──────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _goToAnalytics(context, AttendanceFilter.present),
            child: OverviewStatCard(
              label: 'Present Today',
              value: '${metrics.presentToday}',
              delta: '',
              positive: true,
              icon: Icons.how_to_reg_rounded,
              bg: AppTheme.successLight,
              ic: AppTheme.success,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // ── Absent → Analytics (Absent filter) ─────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _goToAnalytics(context, AttendanceFilter.absent),
            child: OverviewStatCard(
              label: 'Absent',
              value: '${metrics.absentToday}',
              delta: '',
              positive: false,
              icon: Icons.person_off_rounded,
              bg: Theme.of(context).colorScheme.errorContainer,
              ic: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // ── Pending Leaves → Analytics (Late filter) ────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _goToAnalytics(context, AttendanceFilter.late),
            child: OverviewStatCard(
              label: 'Pending Leaves',
              value: '${metrics.pendingLeaves}',
              delta: '',
              positive: false,
              icon: Icons.access_time_rounded,
              bg: AppTheme.warningLight,
              ic: AppTheme.warning,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // ── On Holiday → Analytics (Holiday filter) ─────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _goToAnalytics(context, AttendanceFilter.holiday),
            child: OverviewStatCard(
              label: 'On Holiday',
              value: '$holidayCount',
              delta: '',
              positive: true,
              icon: Icons.holiday_village_rounded,
              bg: AppTheme.successLight,
              ic: AppTheme.success,
            ),
          ),
        ),
      ],
    );
  }
}
