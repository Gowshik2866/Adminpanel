import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/overview_stat_card.dart';
import 'package:sample_app/providers/dashboard_provider.dart';

class StatisticsOverviewRow extends ConsumerWidget {
  const StatisticsOverviewRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);

    return Row(
      children: [
        Expanded(
          child: OverviewStatCard(
            label: 'Total Staff',
            value: '${metrics.totalStaff}',
            delta: '', // Mock delta
            positive: true,
            icon: Icons.groups_rounded,
            bg: AppTheme.primaryLight,
            ic: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
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
        const SizedBox(width: 16),
        Expanded(
          child: OverviewStatCard(
            label: 'Absent',
            value: '${metrics.absentToday}',
            delta: '',
            positive: false,
            icon: Icons.person_off_rounded,
            bg: AppTheme.dangerLight,
            ic: AppTheme.danger,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
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
      ],
    );
  }
}
