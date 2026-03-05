import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/report_provider.dart';
import 'package:sample_app/providers/staff_provider.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/section_title.dart';

class StaffReportsScreen extends ConsumerWidget {
  const StaffReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(reportOverviewProvider);
    final staffList = ref.watch(staffProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Build display list — join staff names with their attendance %
    final staffData = staffList.map((staff) {
      final pct = (metrics.staffAttendancePercent[staff.id] ?? 0.0) * 100;
      return _StaffEntry(
        name: staff.name,
        role: staff.role,
        dept: staff.dept,
        pct: pct,
      );
    }).toList()..sort((a, b) => b.pct.compareTo(a.pct));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'Staff Reports',
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
              title: 'Staff Reports',
              subtitle:
                  'Individual attendance records for all staff members, ranked by performance.',
            ),
            const SizedBox(height: 32),
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
                        Expanded(
                          flex: 3,
                          child: Text(
                            'STAFF MEMBER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'DEPARTMENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: Text(
                            'ATTENDANCE',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.dividerColor),

                  if (staffData.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No staff records found.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  else
                    ...staffData.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      final color = s.pct >= 90
                          ? AppTheme.success
                          : s.pct >= 75
                          ? AppTheme.warning
                          : colorScheme.error;

                      return Column(
                        children: [
                          Container(
                            color: i.isEven
                                ? Colors.transparent
                                : theme.scaffoldBackgroundColor.withValues(
                                    alpha: 0.4,
                                  ),
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
                                          s.name[0].toUpperCase(),
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
                                              s.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              s.role,
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
                                    s.dept,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${s.pct.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (s.pct / 100).clamp(0.0, 1.0),
                                          backgroundColor: theme.dividerColor,
                                          color: color,
                                          minHeight: 5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < staffData.length - 1)
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

class _StaffEntry {
  final String name;
  final String role;
  final String dept;
  final double pct;

  const _StaffEntry({
    required this.name,
    required this.role,
    required this.dept,
    required this.pct,
  });
}
