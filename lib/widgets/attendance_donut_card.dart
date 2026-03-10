import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/dashboard_provider.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/chart_legend.dart';
import 'package:sample_app/widgets/donut_chart_painter.dart';

class AttendanceDonutCard extends ConsumerWidget {
  const AttendanceDonutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(filteredDashboardMetricsProvider);

    // Calculate the rates
    final total = metrics.totalStaff;
    final present = metrics.presentToday;
    final absent = metrics.absentToday;

    // Ensure total isn't 0
    double rate = total > 0 ? present / total : 0;

    String presentPct = total > 0
        ? '${(present / total * 100).round()}%'
        : '0%';
    String absentPct = total > 0 ? '${(absent / total * 100).round()}%' : '0%';
    String latePct = total > 0
        ? '${((total - present - absent) / total * 100).round()}%'
        : '0%'; // Roughly mapping leftover to late

    return Container(
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Overall System Rate',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: DonutChartPainter(
                  value: rate,
                  backgroundColor: Theme.of(context).dividerColor,
                  successColor: AppTheme.success,
                  errorColor: Theme.of(context).colorScheme.error,
                  warningColor: AppTheme.warning,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(rate * 100).round()}%',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'AVERAGE',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          ChartLegend(
            color: AppTheme.success,
            label: 'Present',
            pct: presentPct,
          ),
          SizedBox(height: 12),
          ChartLegend(
            color: Theme.of(context).colorScheme.error,
            label: 'Absent',
            pct: absentPct,
          ),
          SizedBox(height: 12),
          ChartLegend(color: AppTheme.warning, label: 'Late', pct: latePct),
        ],
      ),
    );
  }
}
