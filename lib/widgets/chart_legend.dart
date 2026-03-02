import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';

class ChartLegend extends StatelessWidget {
  final Color color;
  final String label, pct;
  const ChartLegend({
    super.key,
    required this.color,
    required this.label,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Text(
        pct,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
