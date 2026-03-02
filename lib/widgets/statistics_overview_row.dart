import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/overview_stat_card.dart';

class StatisticsOverviewRow extends StatelessWidget {
  const StatisticsOverviewRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OverviewStatCard(
            label: 'Total Staff',
            value: '348',
            delta: '+2%',
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
            value: '320',
            delta: '+1.4%',
            positive: true,
            icon: Icons.how_to_reg_rounded,
            bg: AppTheme.successLight,
            ic: AppTheme.success,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: OverviewStatCard(
            label: 'Absent',
            value: '18',
            delta: '-0.5%',
            positive: false,
            icon: Icons.person_off_rounded,
            bg: AppTheme.dangerLight,
            ic: AppTheme.danger,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OverviewStatCard(
            label: 'Late',
            value: '10',
            delta: '+5%',
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
