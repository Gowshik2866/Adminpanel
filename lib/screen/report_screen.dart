import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/report_provider.dart';
import 'package:sample_app/screen/reports/absence_leave_report_screen.dart';
import 'package:sample_app/screen/reports/department_analysis_screen.dart';
import 'package:sample_app/screen/reports/overall_attendance_screen.dart';
import 'package:sample_app/screen/reports/staff_reports_screen.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/animated_hover_card.dart';
import 'package:sample_app/widgets/section_title.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(reportOverviewProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final List<_ReportSection> sections = [
      _ReportSection(
        title: 'Overall Attendance',
        subtitle:
            'Avg: ${(metrics.overallAttendancePercent * 100).toStringAsFixed(1)}% | ${metrics.totalWorkingDays} Working Days',
        icon: Icons.calendar_month_rounded,
        color: colorScheme.primary,
        destination: const OverallAttendanceScreen(),
      ),
      _ReportSection(
        title: 'Department Analysis',
        subtitle: '${metrics.deptAttendancePercent.length} departments tracked',
        icon: Icons.bar_chart_rounded,
        color: AppTheme.success,
        destination: const DepartmentAnalysisScreen(),
      ),
      _ReportSection(
        title: 'Staff Reports',
        subtitle:
            '${metrics.staffAttendancePercent.length} staff records available',
        icon: Icons.access_time_rounded,
        color: AppTheme.warning,
        destination: const StaffReportsScreen(),
      ),
      _ReportSection(
        title: 'Absence & Leave Report',
        subtitle: 'Detailed absence and leave logs',
        icon: Icons.person_off_rounded,
        color: colorScheme.error,
        destination: const AbsenceLeaveReportScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
              child: SectionTitle(
                title: 'Reports & Exports',
                subtitle:
                    'Select a report category to view detailed data and generate exports.',
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                itemCount: sections.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.6,
                ),
                itemBuilder: (_, i) => _ReportNavCard(section: sections[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _ReportSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget destination;

  const _ReportSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.destination,
  });
}

// ── Navigation card ───────────────────────────────────────────────────────────

class _ReportNavCard extends StatelessWidget {
  final _ReportSection section;
  const _ReportNavCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedHoverCard(
      padding: const EdgeInsets.all(24),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => section.destination)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(section.icon, color: section.color, size: 36),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
          const Spacer(),
          Text(
            section.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            section.subtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
