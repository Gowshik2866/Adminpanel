import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/dashboard_provider.dart';
import 'package:sample_app/widgets/attendance_donut_card.dart';
import 'package:sample_app/widgets/custombar_chart_card.dart';
import 'package:sample_app/widgets/department_summary_card.dart';
import 'package:sample_app/widgets/section_title.dart';
import 'package:sample_app/widgets/statistics_overview_row.dart';
import 'package:sample_app/screens/department_attendance_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredMetrics = ref.watch(filteredDashboardMetricsProvider);
    final currentFilter = ref.watch(dashboardFilterProvider);

    // Labels and icons per filter
    final filterLabels = {
      DashboardFilterType.all: 'All Staff',
      DashboardFilterType.present: 'Present Today',
      DashboardFilterType.absent: 'Absent',
      DashboardFilterType.late: 'Late / On Leave',
      DashboardFilterType.holiday: 'On Holiday',
    };

    final bool isFiltered = currentFilter != DashboardFilterType.all;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              const SectionTitle(
                title: 'Dashboard Overview',
                subtitle: 'System status and high-level attendance metrics.',
              ),
              const SizedBox(height: 32),

              // ── Overview Cards (act as filters) ───────────────────────────
              const StatisticsOverviewRow(),
              const SizedBox(height: 16),

              // ── Active Filter Badge ────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isFiltered
                    ? Align(
                        key: ValueKey(currentFilter),
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_alt_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Showing: ${filterLabels[currentFilter]}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  ref
                                      .read(dashboardFilterProvider.notifier)
                                      .state = DashboardFilterType
                                      .all;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.close_rounded,
                                        size: 13,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Clear',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('none')),
              ),

              // ── Department Summary ─────────────────────────────────────────
              Text(
                'Department Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filteredMetrics.deptAttendancePercent.isEmpty
                    ? Padding(
                        key: const ValueKey('empty-dept'),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No department data for this filter.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : GridView.extent(
                        key: ValueKey(
                          filteredMetrics.deptAttendancePercent.keys.join(),
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        maxCrossAxisExtent: 260,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.6,
                        children: filteredMetrics.deptAttendancePercent.entries
                            .map(
                              (entry) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DepartmentAttendanceDetailScreen(
                                            departmentName: entry.key,
                                          ),
                                    ),
                                  );
                                },
                                child: DepartmentSummaryCard(
                                  dept: entry.key,
                                  percent: entry.value,
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),

              const SizedBox(height: 32),

              // ── Attendance Trends + Overall System Rate ────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return const Column(
                      children: [
                        CustomBarChartCard(),
                        SizedBox(height: 24),
                        AttendanceDonutCard(),
                      ],
                    );
                  }
                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: CustomBarChartCard()),
                      SizedBox(width: 24),
                      Expanded(flex: 2, child: AttendanceDonutCard()),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
