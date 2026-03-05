import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/report_provider.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/section_title.dart';

class OverallAttendanceScreen extends ConsumerWidget {
  const OverallAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(reportOverviewProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final overallPct = (metrics.overallAttendancePercent * 100);

    Color pctColor = overallPct >= 90
        ? AppTheme.success
        : overallPct >= 75
        ? AppTheme.warning
        : colorScheme.error;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'Overall Attendance',
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
              title: 'Overall Attendance',
              subtitle:
                  'System-wide attendance summary across all staff and days.',
            ),
            const SizedBox(height: 32),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  _StatBox(
                    label: 'Overall Rate',
                    value: '${overallPct.toStringAsFixed(1)}%',
                    color: pctColor,
                    icon: Icons.trending_up_rounded,
                  ),
                  _divider(theme),
                  _StatBox(
                    label: 'Working Days',
                    value: '${metrics.totalWorkingDays}',
                    color: colorScheme.primary,
                    icon: Icons.calendar_today_rounded,
                  ),
                  _divider(theme),
                  _StatBox(
                    label: 'Staff Tracked',
                    value: '${metrics.staffAttendancePercent.length}',
                    color: AppTheme.success,
                    icon: Icons.people_alt_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Per-staff breakdown
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Staff Attendance Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: theme.dividerColor),
                  if (metrics.staffAttendancePercent.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No attendance data available.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  else
                    ...metrics.staffAttendancePercent.entries.map((e) {
                      final pct = e.value * 100;
                      final color = pct >= 90
                          ? AppTheme.success
                          : pct >= 75
                          ? AppTheme.warning
                          : colorScheme.error;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Text(
                                    e.key.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 160,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${pct.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: e.value.clamp(0.0, 1.0),
                                          backgroundColor: theme.dividerColor,
                                          color: color,
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _divider(ThemeData theme) => Container(
    width: 1,
    height: 60,
    color: theme.dividerColor,
    margin: const EdgeInsets.symmetric(horizontal: 24),
  );
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
