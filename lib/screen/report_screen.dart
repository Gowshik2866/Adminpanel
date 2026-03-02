import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/report_card_interactive.dart';
import 'package:sample_app/widgets/section_title.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const List<Map<String, dynamic>> reportTypes = [
    {
      'title': 'Monthly Attendance',
      'sub': 'Jan - Feb 2026',
      'icon': Icons.calendar_month,
      'color': AppTheme.primary,
    },
    {
      'title': 'Department Analysis',
      'sub': 'All Engineering Depts',
      'icon': Icons.bar_chart,
      'color': AppTheme.success,
    },
    {
      'title': 'Late Arrival Report',
      'sub': 'Last 30 days',
      'icon': Icons.access_time,
      'color': AppTheme.warning,
    },
    {
      'title': 'Absence & Leave Report',
      'sub': 'Unapproved leaves',
      'icon': Icons.person_off,
      'color': AppTheme.danger,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
              child: SectionTitle(
                title: 'Reports & Exports',
                subtitle: 'Generate and download attendance reports.',
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                itemCount: reportTypes.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.6,
                ),
                itemBuilder: (_, i) =>
                    ReportCardInteractive(item: reportTypes[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
