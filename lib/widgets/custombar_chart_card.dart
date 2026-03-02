import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';

class CustomBarChartCard extends StatelessWidget {
  const CustomBarChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Trends (Monthly)',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          _buildBarRow('Computer Science (CSE)', 95),
          _buildBarRow('Electronics (ECE)', 88),
          _buildBarRow('Information Technology (IT)', 91),
          _buildBarRow('Civil Engineering', 84),
          _buildBarRow('Mechanical (MECH)', 75),
          _buildBarRow('MBA (MBA)', 88),
        ],
      ),
    );
  }

  Widget _buildBarRow(String department, int percent) {
    final Color barColor = percent >= 90
        ? AppTheme.success
        : percent >= 80
        ? AppTheme.warning
        : AppTheme.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  department,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent / 100,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
