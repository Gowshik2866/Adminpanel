import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/report_card_interactive.dart';
import 'package:sample_app/widgets/section_title.dart';
import 'package:sample_app/providers/report_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(reportOverviewProvider);

    final List<Map<String, dynamic>> reportTypes = [
      {
        'title': 'Overall Attendance',
        'sub':
            'Avg: ${(metrics.overallAttendancePercent * 100).toStringAsFixed(1)}% | ${metrics.totalWorkingDays} Days',
        'icon': Icons.calendar_month,
        'color': AppTheme.primary,
      },
      {
        'title': 'Department Analysis',
        'sub': '${metrics.deptAttendancePercent.length} Depts track record',
        'icon': Icons.bar_chart,
        'color': AppTheme.success,
      },
      {
        'title': 'Staff Reports',
        'sub': '${metrics.staffAttendancePercent.length} Staff records',
        'icon': Icons.access_time,
        'color': AppTheme.warning,
      },
      {
        'title': 'Absence & Leave Report',
        'sub': 'Export detailed leave logs',
        'icon': Icons.person_off,
        'color': AppTheme.danger,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(32, 32, 32, 16),
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
