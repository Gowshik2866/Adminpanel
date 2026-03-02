import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';

class DonutChartPainter extends CustomPainter {
  final double value;
  const DonutChartPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const strokeWidth = 20.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppTheme.border.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    const gaps = [0.0, 0.89, 0.96, 1.0];
    const colors = [AppTheme.success, AppTheme.danger, AppTheme.warning];

    for (int i = 0; i < 3; i++) {
      final start = gaps[i] * 2 * 3.14159;
      final sweep = (gaps[i + 1] - gaps[i]) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2 + start,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) =>
      oldDelegate.value != value;
}
