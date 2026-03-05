import 'package:flutter/material.dart';

class DonutChartPainter extends CustomPainter {
  final double value;
  final Color backgroundColor;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;

  const DonutChartPainter({
    required this.value,
    required this.backgroundColor,
    required this.successColor,
    required this.errorColor,
    required this.warningColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const strokeWidth = 20.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    const gaps = [0.0, 0.89, 0.96, 1.0];
    final colors = [successColor, errorColor, warningColor];

    for (int i = 0; i < 3; i++) {
      final startAngle = -3.14159 / 2 + gaps[i] * 2 * 3.14159;
      final sweepAngle = (gaps[i + 1] - gaps[i]) * 2 * 3.14159;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
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
      oldDelegate.value != value ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.successColor != successColor ||
      oldDelegate.errorColor != errorColor ||
      oldDelegate.warningColor != warningColor;
}
