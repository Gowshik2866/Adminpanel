import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/overview_stat_card.dart';
import 'package:sample_app/providers/dashboard_provider.dart';

class StatisticsOverviewRow extends StatelessWidget {
  final DashboardMetrics metrics;
  const StatisticsOverviewRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OverviewStatCard(
            label: 'Total Staff',
            value: '',
            delta: '',
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
            value: '',
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
            value: '',
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
            value: '',
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
