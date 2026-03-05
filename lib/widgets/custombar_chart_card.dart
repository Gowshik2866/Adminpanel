import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/department_trend_provider.dart';
import 'package:sample_app/providers/staff_provider.dart';

class CustomBarChartCard extends ConsumerStatefulWidget {
  const CustomBarChartCard({super.key});

  @override
  ConsumerState<CustomBarChartCard> createState() => _CustomBarChartCardState();
}

class _CustomBarChartCardState extends ConsumerState<CustomBarChartCard> {
  TrendPeriod _selectedPeriod = TrendPeriod.today;

  Color _getDepartmentColor(BuildContext context, String dept) {
    final surface = Theme.of(context).colorScheme.onSurface;
    switch (dept.toUpperCase()) {
      case 'CSE':
      case 'COMPUTER SCIENCE':
        return Colors.blue;
      case 'AIDS':
      case 'AI&DS':
        return Colors.purple;
      case 'MECH':
      case 'MECHANICAL':
        return Colors.green;
      case 'ECE':
      case 'ELECTRONICS':
        return Colors.red;
      case 'MBA':
        return surface;
      case 'CSBS':
      case 'IT':
      case 'INFORMATION TECHNOLOGY':
        return Colors.orange;
      default:
        if (dept.toUpperCase().contains('CSE')) return Colors.blue;
        if (dept.toUpperCase().contains('AIDS')) return Colors.purple;
        if (dept.toUpperCase().contains('MECH')) return Colors.green;
        if (dept.toUpperCase().contains('ECE')) return Colors.red;
        if (dept.toUpperCase().contains('MBA')) return surface;
        if (dept.toUpperCase().contains('CSBS') ||
            dept.toUpperCase() == 'IT' ||
            dept.toUpperCase().contains('INFORMATION TECHNOLOGY')) {
          return Colors.orange;
        }
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildToggleBtn(String label, TrendPeriod p) {
    bool isSelected = _selectedPeriod == p;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = p;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(List<String> depts) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: depts.map((d) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getDepartmentColor(context, d),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              d,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChart(Map<String, List<double>> deptData, List<String> xLabels) {
    double minVal = 100.0;
    double maxVal = 0.0;

    // Auto scale Y based on current dataset values
    for (var vals in deptData.values) {
      var checkVals = vals;
      if (_selectedPeriod == TrendPeriod.today) {
        checkVals = vals.isEmpty
            ? []
            : vals.sublist(vals.length >= 3 ? vals.length - 3 : 0);
      }
      for (var v in checkVals) {
        if (v < minVal) minVal = v;
        if (v > maxVal) maxVal = v;
      }
    }

    if (minVal > maxVal) {
      minVal = 0;
      maxVal = 100;
    }

    double minY = (minVal / 5).floor() * 5.0;
    double maxY = (maxVal / 5).ceil() * 5.0;

    if (maxY - minY < 10) {
      maxY = minY + 10;
    }
    if (minY < 0) minY = 0;
    if (maxY > 100) maxY = 100;

    List<double> yLabels = [];
    for (int i = 0; i < 5; i++) {
      yLabels.add(minY + (maxY - minY) * i / 4);
    }
    yLabels = yLabels.reversed.toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Y-axis labels
        SizedBox(
          width: 32,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...yLabels.map(
                (yVal) => Text(
                  '${yVal.toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              SizedBox(height: 20), // Padding for X-axis labels
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight - 20;

              final chartWidth = width - 10;
              const startX = 5.0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Grid lines
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (_) => Container(
                          height: 1,
                          width: double.infinity,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),

                  // The Line chart painter
                  Positioned(
                    top: 0,
                    left: 0,
                    width: width,
                    height: height,
                    child: CustomPaint(
                      painter: LineChartPainter(
                        deptData: deptData,
                        getColor: (d) => _getDepartmentColor(context, d),
                        period: _selectedPeriod,
                        minY: minY,
                        maxY: maxY,
                        cardColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ),

                  // X-axis labels
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 20,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(xLabels.length, (i) {
                        if (xLabels[i].isEmpty) return SizedBox();
                        double x =
                            startX +
                            i *
                                (xLabels.length > 1
                                    ? chartWidth / (xLabels.length - 1)
                                    : 0);
                        if (xLabels.length == 1) x = startX + chartWidth / 2;
                        return Positioned(
                          left: x - 30,
                          top: 4,
                          width: 60,
                          child: Text(
                            xLabels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Tooltips
                  ...deptData.entries.expand((entry) {
                    final dept = entry.key;
                    var values = entry.value;
                    if (_selectedPeriod == TrendPeriod.today) {
                      values = values.isEmpty
                          ? []
                          : values.sublist(
                              values.length >= 3 ? values.length - 3 : 0,
                            );
                    }

                    List<Widget> dots = [];
                    double xOffset = values.length > 1
                        ? chartWidth / (values.length - 1)
                        : 0;

                    for (int i = 0; i < values.length; i++) {
                      double x = startX + i * xOffset;
                      if (values.length == 1) x = startX + chartWidth / 2;

                      double val = values[i];
                      if (val > maxY) val = maxY;
                      if (val < minY) val = minY;

                      double y =
                          height - (((val - minY) / (maxY - minY)) * height);
                      bool isTodayPoint =
                          (_selectedPeriod == TrendPeriod.today &&
                          i == values.length - 1);
                      double hitBoxSize = isTodayPoint ? 40 : 30;

                      String tooltipMsg = '$dept\n${val.toStringAsFixed(1)}%';
                      if (isTodayPoint && values.length > 1) {
                        double diff = val - values[values.length - 2];
                        tooltipMsg += diff >= 0
                            ? ' (+${diff.toStringAsFixed(1)}%)'
                            : ' (${diff.toStringAsFixed(1)}%)';
                      }

                      dots.add(
                        Positioned(
                          left: x - (hitBoxSize / 2),
                          top: y - (hitBoxSize / 2),
                          width: hitBoxSize,
                          height: hitBoxSize,
                          child: Tooltip(
                            message: tooltipMsg,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).cardColor.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            textStyle: TextStyle(
                              color: _getDepartmentColor(context, dept),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ),
                      );
                    }
                    return dots;
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStaff = ref.watch(staffProvider);
    final uniqueDepts = allStaff.map((s) => s.dept).toSet().toList();

    // Fetch data
    final Map<String, List<double>> deptData = {};
    for (var dept in uniqueDepts) {
      final args = DepartmentTrendArgs(
        department: dept,
        period: _selectedPeriod,
      );
      deptData[dept] = ref.watch(departmentTrendProvider(args));
    }

    // Build xLabels
    List<String> xLabels = [];
    final now = DateTime.now();

    if (_selectedPeriod == TrendPeriod.today) {
      for (int i = 2; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        if (i == 0) {
          xLabels.add('Today');
        } else {
          xLabels.add('${d.day}/${d.month}');
        }
      }
    } else if (_selectedPeriod == TrendPeriod.week) {
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        xLabels.add('${d.day}/${d.month}');
      }
    } else if (_selectedPeriod == TrendPeriod.month) {
      for (int i = 29; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        // Show xLabels only every 5th day to avoid crowding
        if (i % 5 == 0 || i == 0 || i == 29) {
          xLabels.add('${d.day}/${d.month}');
        } else {
          xLabels.add('');
        }
      }
    }

    return Container(
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Trends',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn('Today', TrendPeriod.today),
                    _buildToggleBtn('Week', TrendPeriod.week),
                    _buildToggleBtn('Month', TrendPeriod.month),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: _buildChart(deptData, xLabels),
          ),
          SizedBox(height: 32),
          _buildLegend(uniqueDepts),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final Map<String, List<double>> deptData;
  final Color Function(String) getColor;
  final TrendPeriod period;
  final double minY;
  final double maxY;
  final Color cardColor;

  LineChartPainter({
    required this.deptData,
    required this.getColor,
    required this.period,
    required this.minY,
    required this.maxY,
    required this.cardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (deptData.isEmpty) return;

    final width = size.width;
    final height = size.height;

    final chartWidth = width - 10;
    const startX = 5.0;

    for (var entry in deptData.entries) {
      final dept = entry.key;
      var values = entry.value;

      if (period == TrendPeriod.today) {
        values = values.isEmpty
            ? []
            : values.sublist(values.length >= 3 ? values.length - 3 : 0);
      }

      if (values.isEmpty) continue;

      final lineColor = getColor(dept);
      final paintLine = Paint()
        ..color = lineColor.withValues(
          alpha: period == TrendPeriod.month ? 0.6 : 1.0,
        )
        ..strokeWidth = period == TrendPeriod.month ? 1.5 : 2.5
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      final path = Path();
      final points = <Offset>[];

      double xOffset = values.length > 1
          ? chartWidth / (values.length - 1)
          : chartWidth / 2;

      for (int i = 0; i < values.length; i++) {
        double x = startX + i * xOffset;
        if (values.length == 1) {
          x = startX + chartWidth / 2;
        }

        double val = values[i];
        if (val > maxY) {
          val = maxY;
        }
        if (val < minY) {
          val = minY;
        }

        double y = height - (((val - minY) / (maxY - minY)) * height);
        points.add(Offset(x, y));

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          // Smooth curve
          double prevX = startX + (i - 1) * xOffset;

          double prevVal = values[i - 1];
          if (prevVal > maxY) prevVal = maxY;
          if (prevVal < minY) prevVal = minY;
          double prevY = height - (((prevVal - minY) / (maxY - minY)) * height);

          double controlX1 = prevX + (x - prevX) / 2;
          double controlY1 = prevY;
          double controlX2 = prevX + (x - prevX) / 2;
          double controlY2 = y;

          path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        }
      }

      if (values.length > 1) {
        canvas.drawPath(path, paintLine);
      }

      final paintDot = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      final dotInner = Paint()
        ..color = cardColor
        ..style = PaintingStyle.fill;

      for (int i = 0; i < points.length; i++) {
        var p = points[i];
        bool isTodayPoint =
            (period == TrendPeriod.today && i == points.length - 1);
        double pointRadius = period == TrendPeriod.month ? 2.0 : 4.0;
        if (isTodayPoint) pointRadius = 6.0;

        canvas.drawCircle(
          p,
          pointRadius + (isTodayPoint ? 2.0 : 1.0),
          paintDot,
        );
        canvas.drawCircle(p, pointRadius, dotInner);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return true;
  }
}
