import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/overview_stat_card.dart';
import 'package:sample_app/providers/dashboard_provider.dart';
import 'package:sample_app/providers/holiday_provider.dart';

import 'package:sample_app/widgets/app_shell.dart';

class StatisticsOverviewRow extends ConsumerWidget {
  const StatisticsOverviewRow({super.key});

  // ── Filter helpers ──────────────────────────────────────────────────────────

  void _setFilter(
    BuildContext context,
    WidgetRef ref,
    DashboardFilterType filter,
  ) {
    ref.read(dashboardFilterProvider.notifier).state = filter;
  }

  Widget _buildCardWrap(
    BuildContext context,
    WidgetRef ref,
    DashboardFilterType type,
    bool isSelected,
    Widget child, {
    VoidCallback? onTapOverride,
  }) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: onTapOverride ?? () => _setFilter(context, ref, type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    final holidayCount = ref.watch(dashboardHolidayCountProvider);
    final currentFilter = ref.watch(dashboardFilterProvider);

    return Row(
      children: [
        // ── Total Staff ─────────────────────────────────────────────────────
        _buildCardWrap(
          context,
          ref,
          DashboardFilterType.all,
          currentFilter == DashboardFilterType.all,
          OverviewStatCard(
            label: 'Total Staff',
            value: '${metrics.totalStaff}',
            delta: '',
            positive: true,
            icon: Icons.groups_rounded,
            bg: Theme.of(context).colorScheme.primaryContainer,
            ic: Theme.of(context).colorScheme.primary,
          ),
          onTapOverride: () {
            context.findAncestorStateOfType<AppShellState>()?.setNavIndex(1);
          },
        ),
        const SizedBox(width: 16),

        // ── Present Today ───────────────────────────────────────────────────
        _buildCardWrap(
          context,
          ref,
          DashboardFilterType.present,
          currentFilter == DashboardFilterType.present,
          OverviewStatCard(
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

        // ── Absent ────────────────────────────────────────────────────────
        _buildCardWrap(
          context,
          ref,
          DashboardFilterType.absent,
          currentFilter == DashboardFilterType.absent,
          OverviewStatCard(
            label: 'Absent',
            value: '${metrics.absentToday}',
            delta: '',
            positive: false,
            icon: Icons.person_off_rounded,
            bg: Theme.of(context).colorScheme.errorContainer,
            ic: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(width: 16),

        // ── Pending Leaves (Late) ───────────────────────────────────────────
        _buildCardWrap(
          context,
          ref,
          DashboardFilterType.late,
          currentFilter == DashboardFilterType.late,
          OverviewStatCard(
            label: 'Late', // Changed to match prompt "Late"
            value:
                '${metrics.pendingLeaves}', // Still using pendingLeaves for count as metrics might define it there
            delta: '',
            positive: false,
            icon: Icons.access_time_rounded,
            bg: AppTheme.warningLight,
            ic: AppTheme.warning,
          ),
        ),
        const SizedBox(width: 16),

        // ── On Holiday ─────────────────────────────────────────────────────
        _buildCardWrap(
          context,
          ref,
          DashboardFilterType.holiday,
          currentFilter == DashboardFilterType.holiday,
          OverviewStatCard(
            label: 'On Holiday',
            value: '$holidayCount',
            delta: '',
            positive: true,
            icon: Icons.holiday_village_rounded,
            bg: AppTheme.successLight,
            ic: AppTheme.success,
          ),
        ),
      ],
    );
  }
}
