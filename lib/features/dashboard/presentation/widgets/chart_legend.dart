import 'package:flutter/material.dart';

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
      SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Text(
        pct,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
