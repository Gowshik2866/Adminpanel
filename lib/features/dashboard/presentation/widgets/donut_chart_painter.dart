import 'package:flutter/material.dart';

class DonutChartPainter extends CustomPainter {
  final double presentRate;
  final double absentRate;
  final double lateRate;
  final Color backgroundColor;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;

  const DonutChartPainter({
    required this.presentRate,
    required this.absentRate,
    required this.lateRate,
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

    final totalPct = presentRate + absentRate + lateRate;
    final normalizedPresent = totalPct > 0 ? presentRate / totalPct : 0.0;
    final normalizedAbsent = totalPct > 0 ? absentRate / totalPct : 0.0;

    final gaps = [
      0.0,
      normalizedPresent,
      normalizedPresent + normalizedAbsent,
      1.0,
    ];
    final colors = [successColor, errorColor, warningColor];

    for (int i = 0; i < 3; i++) {
      final startAngle = -3.14159 / 2 + gaps[i] * 2 * 3.14159;
      final sweepAngle = (gaps[i + 1] - gaps[i]) * 2 * 3.14159;

      if (sweepAngle > 0) {
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
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) =>
      oldDelegate.presentRate != presentRate ||
      oldDelegate.absentRate != absentRate ||
      oldDelegate.lateRate != lateRate ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.successColor != successColor ||
      oldDelegate.errorColor != errorColor ||
      oldDelegate.warningColor != warningColor;
}
