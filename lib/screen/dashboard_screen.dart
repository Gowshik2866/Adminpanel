import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/widgets/attendance_donut_card.dart';
import 'package:sample_app/widgets/custombar_chart_card.dart';
import 'package:sample_app/widgets/department_summary_card.dart';
import 'package:sample_app/widgets/section_title.dart';
import 'package:sample_app/widgets/statistics_overview_row.dart';
import 'package:sample_app/providers/dashboard_provider.dart';
import 'package:sample_app/screens/department_attendance_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Dashboard Overview',
                subtitle: "System status and high-level attendance metrics.",
              ),
              SizedBox(height: 32),
              const StatisticsOverviewRow(),
              SizedBox(height: 32),
              Text(
                'Department Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16),
              GridView.extent(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.6,
                children:
                    metrics.deptAttendancePercent.entries
                        .map((entry) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
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
                          );
                        })
                        .toList()
                        .isNotEmpty
                    ? metrics.deptAttendancePercent.entries.map((entry) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
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
                        );
                      }).toList()
                    : [
                        // Fallback if empty
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DepartmentAttendanceDetailScreen(
                                      departmentName: 'Computer Science',
                                    ),
                              ),
                            );
                          },
                          child: const DepartmentSummaryCard(
                            dept: 'Computer Science',
                            percent: 0.0,
                          ),
                        ),
                      ],
              ),
              SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        CustomBarChartCard(),
                        SizedBox(height: 24),
                        AttendanceDonutCard(),
                      ],
                    );
                  }
                  return Row(
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
