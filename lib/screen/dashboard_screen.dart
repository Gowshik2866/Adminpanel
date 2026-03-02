import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/attendance_donut_card.dart';
import 'package:sample_app/widgets/custombar_chart_card.dart';
import 'package:sample_app/widgets/department_summary_card.dart';
import 'package:sample_app/widgets/section_title.dart';
import 'package:sample_app/widgets/statistics_overview_row.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Dashboard Overview',
                subtitle: "System status and high-level attendance metrics.",
              ),
              const SizedBox(height: 32),
              const StatisticsOverviewRow(),
              const SizedBox(height: 32),
              const Text(
                'Department Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.extent(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: const [
                  DepartmentSummaryCard(
                    dept: 'Computer Science',
                    percent: 0.94,
                  ),
                  DepartmentSummaryCard(
                    dept: 'Electronics (ECE)',
                    percent: 0.88,
                  ),
                  DepartmentSummaryCard(dept: 'Mechanical', percent: 0.78),
                  DepartmentSummaryCard(dept: 'CSBS', percent: 0.85),
                  DepartmentSummaryCard(dept: 'MBA', percent: 0.88),
                ],
              ),
              const SizedBox(height: 32),
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
