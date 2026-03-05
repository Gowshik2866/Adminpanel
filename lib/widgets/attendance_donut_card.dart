import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/chart_legend.dart';
import 'package:sample_app/widgets/donut_chart_painter.dart';

class AttendanceDonutCard extends StatelessWidget {
  const AttendanceDonutCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                  value: 0.89,
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
                        '89%',
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
          const ChartLegend(
            color: AppTheme.success,
            label: 'Present',
            pct: '89%',
          ),
          SizedBox(height: 12),
          ChartLegend(
            color: Theme.of(context).colorScheme.error,
            label: 'Absent',
            pct: '7%',
          ),
          SizedBox(height: 12),
          ChartLegend(color: AppTheme.warning, label: 'Late', pct: '4%'),
        ],
      ),
    );
  }
}
