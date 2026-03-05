import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/providers/attendance_provider.dart';
import 'package:sample_app/providers/staff_provider.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/section_title.dart';

class AbsenceLeaveReportScreen extends ConsumerWidget {
  const AbsenceLeaveReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffList = ref.watch(staffProvider);
    final allRecords = ref.watch(attendanceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Compute per-staff absence & leave counts
    final data =
        staffList.map((staff) {
          final staffRecords = allRecords.where((r) => r.staffId == staff.id);
          int absentDays = 0;
          int leaveDays = 0;
          for (final r in staffRecords) {
            if (r.status == AttendanceStatus.absent) absentDays++;
            if (r.status == AttendanceStatus.leave) leaveDays++;
          }
          return _AbsenceEntry(
            name: staff.name,
            dept: staff.dept,
            role: staff.role,
            absentDays: absentDays,
            leaveDays: leaveDays,
          );
        }).toList()..sort(
          (a, b) => (b.absentDays + b.leaveDays).compareTo(
            a.absentDays + a.leaveDays,
          ),
        );

    final totalAbsent = data.fold<int>(0, (s, e) => s + e.absentDays);
    final totalLeave = data.fold<int>(0, (s, e) => s + e.leaveDays);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'Absence & Leave Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Absence & Leave Report',
              subtitle:
                  'Detailed absence and leave logs for all staff members.',
            ),
            const SizedBox(height: 32),

            // Summary Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  _SummaryTile(
                    label: 'Total Absent Days',
                    value: '$totalAbsent',
                    color: colorScheme.error,
                    icon: Icons.person_off_rounded,
                  ),
                  Container(
                    width: 1,
                    height: 56,
                    color: theme.dividerColor,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _SummaryTile(
                    label: 'Total Leave Days',
                    value: '$totalLeave',
                    color: AppTheme.warning,
                    icon: Icons.event_busy_rounded,
                  ),
                  Container(
                    width: 1,
                    height: 56,
                    color: theme.dividerColor,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _SummaryTile(
                    label: 'Staff Affected',
                    value:
                        '${data.where((e) => e.absentDays + e.leaveDays > 0).length}',
                    color: colorScheme.primary,
                    icon: Icons.people_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Detail Table
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _HeaderText('STAFF MEMBER')),
                        Expanded(flex: 2, child: _HeaderText('DEPARTMENT')),
                        SizedBox(
                          width: 100,
                          child: _HeaderText('ABSENT', align: TextAlign.center),
                        ),
                        SizedBox(
                          width: 100,
                          child: _HeaderText('LEAVE', align: TextAlign.center),
                        ),
                        SizedBox(
                          width: 80,
                          child: _HeaderText('TOTAL', align: TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.dividerColor),

                  if (data.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No absence/leave data found.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  else
                    ...data.asMap().entries.map((mapEntry) {
                      final i = mapEntry.key;
                      final e = mapEntry.value;
                      final total = e.absentDays + e.leaveDays;
                      final badColor = total > 5
                          ? colorScheme.error
                          : total > 2
                          ? AppTheme.warning
                          : AppTheme.success;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            colorScheme.primaryContainer,
                                        child: Text(
                                          e.name[0].toUpperCase(),
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              e.role,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    e.dept,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${e.absentDays}d',
                                        style: TextStyle(
                                          color: colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningLight,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${e.leaveDays}d',
                                        style: const TextStyle(
                                          color: AppTheme.warning,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '$total',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: badColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < data.length - 1)
                            Divider(height: 1, color: theme.dividerColor),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _HeaderText(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _AbsenceEntry {
  final String name;
  final String dept;
  final String role;
  final int absentDays;
  final int leaveDays;

  const _AbsenceEntry({
    required this.name,
    required this.dept,
    required this.role,
    required this.absentDays,
    required this.leaveDays,
  });
}
