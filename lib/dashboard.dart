import 'package:enggstaff_dashboard/app%20theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../main.dart' show appTheme;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _chartView = 'Week';

  @override
  void initState() {
    super.initState();
    appTheme.addListener(() => setState(() {}));
  }

  final List<Map<String, dynamic>> _stats = [
    {
      'label': 'Total Staff',
      'value': 158,
      'change': '+2%',
      'icon': Icons.people_rounded,
      'positive': true
    },
    {
      'label': 'Present Today',
      'value': 145,
      'change': '+5%',
      'icon': Icons.check_circle_rounded,
      'positive': true
    },
    {
      'label': 'Absent',
      'value': 13,
      'change': '-1%',
      'icon': Icons.cancel_rounded,
      'positive': false
    },
    {
      'label': 'Late',
      'value': 2,
      'change': '+0.5%',
      'icon': Icons.alarm_rounded,
      'positive': null
    },
    {
      'label': 'On Holiday',
      'value': 158,
      'change': '0%',
      'icon': Icons.business_rounded,
      'positive': null
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _chartData = {
    'Week': [
      {'day': 'Mon', 'present': 138},
      {'day': 'Tue', 'present': 145},
      {'day': 'Wed', 'present': 142},
      {'day': 'Thu', 'present': 150},
      {'day': 'Fri', 'present': 145},
      {'day': 'Sat', 'present': 90},
      {'day': 'Sun', 'present': 10},
    ],
    'Today': [
      {'day': '9AM', 'present': 100},
      {'day': '10AM', 'present': 130},
      {'day': '11AM', 'present': 145},
      {'day': '12PM', 'present': 140},
      {'day': '1PM', 'present': 120},
      {'day': '2PM', 'present': 145},
      {'day': '3PM', 'present': 143},
    ],
    'Month': [
      {'day': 'W1', 'present': 140},
      {'day': 'W2', 'present': 148},
      {'day': 'W3', 'present': 145},
      {'day': 'W4', 'present': 152},
    ],
  };

  final List<Map<String, dynamic>> _depts = [
    {
      'code': 'CSE',
      'name': 'Computer Science',
      'icon': Icons.school_rounded,
      'color': Color(0xFF6366F1),
      'pct': 97
    },
    {
      'code': 'AI&DS',
      'name': 'Artificial Intelligence',
      'icon': Icons.smart_toy_rounded,
      'color': Color(0xFF3B82F6),
      'pct': 100
    },
    {
      'code': 'MECH',
      'name': 'Mechanical Engg.',
      'icon': Icons.settings_rounded,
      'color': Color(0xFFF97316),
      'pct': 89
    },
    {
      'code': 'ECE',
      'name': 'Electronics & Comm.',
      'icon': Icons.memory_rounded,
      'color': Color(0xFFA855F7),
      'pct': 100
    },
    {
      'code': 'MBA',
      'name': 'Business Admin.',
      'icon': Icons.business_center_rounded,
      'color': Color(0xFF10B981),
      'pct': 90
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsRow(),
          const SizedBox(height: 20),
          _buildMidRow(),
          const SizedBox(height: 20),
          _buildDeptSummary(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final t = appTheme;
    return LayoutBuilder(builder: (ctx, cons) {
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: _stats
            .map((s) => SizedBox(
                  width: (cons.maxWidth - 56) / 5,
                  child: _StatCard(stat: s, theme: t),
                ))
            .toList(),
      );
    });
  }

  Widget _buildMidRow() {
    return LayoutBuilder(builder: (ctx, cons) {
      final isWide = cons.maxWidth > 600;
      return isWide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: _buildAttendanceChart()),
              const SizedBox(width: 16),
              SizedBox(width: 220, child: _buildSystemRate()),
            ])
          : Column(children: [
              _buildAttendanceChart(),
              const SizedBox(height: 16),
              _buildSystemRate(),
            ]);
    });
  }

  Widget _buildAttendanceChart() {
    final t = appTheme;
    final data = _chartData[_chartView]!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: t.bgCard, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attendance Trends',
                      style: TextStyle(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  Text('Visualization of weekly staff presence',
                      style: TextStyle(color: t.textMuted, fontSize: 12)),
                ],
              ),
              const Spacer(),
              ...['Today', 'Week', 'Month'].map((v) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _chartView = v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              _chartView == v ? t.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(v,
                            style: TextStyle(
                              color:
                                  _chartView == v ? Colors.white : t.iconMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: CustomPaint(
                key: ValueKey(_chartView),
                size: const Size(double.infinity, 180),
                painter: _LineChartPainter(data: data, dotBg: t.chartDotBg),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data
                .map((d) => Text(d['day'],
                    style: TextStyle(color: t.textMuted, fontSize: 11)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemRate() {
    final t = appTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: t.bgCard, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall System Rate',
                    style: TextStyle(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                Text('System performance index',
                    style: TextStyle(color: t.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _DonutPainter(
                  pct: 0.92,
                  trackColor: t.donutTrack,
                  textColor: t.textPrimary),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _miniStat(
                      'EFFICIENCY', 'Optimal', const Color(0xFF10B981), t)),
              const SizedBox(width: 12),
              Expanded(child: _miniStat('REPORTED', 'Daily', t.textPrimary, t)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color valueColor, AppTheme t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration:
          BoxDecoration(color: t.bgSub, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: t.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDeptSummary() {
    final t = appTheme;
    return Column(
      children: [
        Row(
          children: [
            Text('Department Summary',
                style: TextStyle(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text('View All Details →',
                  style: TextStyle(
                      color: t.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (ctx, cons) {
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: _depts
                .map((d) => SizedBox(
                      width: (cons.maxWidth - 56) / 5,
                      child: _DeptCard(dept: d, theme: t),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;
  final AppTheme theme;
  const _StatCard({required this.stat, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final isPos = stat['positive'];
    final changeColor = isPos == null
        ? t.textMuted
        : isPos
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: t.bgCard, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(stat['icon'], color: t.accent, size: 22),
              Text(stat['change'],
                  style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(stat['label'],
              style: TextStyle(color: t.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text('${stat['value']}',
              style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ─── Dept Card ────────────────────────────────────────────────────────────────
class _DeptCard extends StatefulWidget {
  final Map<String, dynamic> dept;
  final AppTheme theme;
  const _DeptCard({required this.dept, required this.theme});
  @override
  State<_DeptCard> createState() => _DeptCardState();
}

class _DeptCardState extends State<_DeptCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.dept;
    final t = widget.theme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.bgCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                      color: (d['color'] as Color).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8))
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(d['icon'], color: d['color'], size: 24),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: const Size(52, 52),
                        painter: _RingPainter(
                          pct: d['pct'] / 100.0,
                          color: d['color'],
                          trackColor: t.donutTrack,
                        ),
                      ),
                      Center(
                        child: Text('${d['pct']}%',
                            style: TextStyle(
                                color: t.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(d['code'],
                style: TextStyle(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            const SizedBox(height: 2),
            Text(d['name'], style: TextStyle(color: t.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color dotBg;
  const _LineChartPainter({required this.data, required this.dotBg});

  @override
  void paint(Canvas canvas, Size size) {
    const maxVal = 158.0;
    final n = data.length;
    if (n < 2) return;

    final pts = List.generate(n, (i) {
      final x = i / (n - 1) * size.width;
      final y = size.height - (data[i]['present'] / maxVal) * size.height;
      return Offset(x, y);
    });

    final areaPath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var p in pts.skip(1)) areaPath.lineTo(p.dx, p.dy);
    areaPath
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.3),
            const Color(0xFF3B82F6).withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var p in pts.skip(1)) linePath.lineTo(p.dx, p.dy);
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF3B82F6)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var p in pts) {
      canvas.drawCircle(p, 4, Paint()..color = const Color(0xFF3B82F6));
      canvas.drawCircle(p, 3, Paint()..color = dotBg);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.data != data || old.dotBg != dotBg;
}

class _DonutPainter extends CustomPainter {
  final double pct;
  final Color trackColor;
  final Color textColor;
  const _DonutPainter(
      {required this.pct, required this.trackColor, required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const stroke = 16.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
        rect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..color = trackColor
          ..strokeWidth = stroke
          ..style = PaintingStyle.stroke);

    canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * pct,
        false,
        Paint()
          ..color = const Color(0xFF3B82F6)
          ..strokeWidth = stroke
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    final tp1 = TextPainter(
      text: TextSpan(
          text: '${(pct * 100).round()}%',
          style: TextStyle(
              color: textColor, fontSize: 28, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp1.paint(canvas, center - Offset(tp1.width / 2, tp1.height / 2 + 8));

    final tp2 = TextPainter(
      text: TextSpan(
          text: 'AVERAGE',
          style: TextStyle(
              color: trackColor == const Color(0xFF1E293B)
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
              fontSize: 10,
              letterSpacing: 2)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, center - Offset(tp2.width / 2, -tp1.height / 2 + 4));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.pct != pct || old.trackColor != trackColor;
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  final Color trackColor;
  const _RingPainter(
      {required this.pct, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
        rect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..color = trackColor
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * pct,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.color != color || old.trackColor != trackColor;
}
