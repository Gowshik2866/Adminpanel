import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/attendance.dart';
import 'package:sample_app/models/staff.dart';
import 'package:sample_app/providers/attendance_provider.dart';
import 'package:sample_app/providers/staff_provider.dart';
import 'package:sample_app/providers/department_trend_provider.dart';
import 'package:sample_app/theme/app_theme.dart';

class DepartmentAttendanceDetailScreen extends ConsumerStatefulWidget {
  final String departmentName;

  const DepartmentAttendanceDetailScreen({
    super.key,
    required this.departmentName,
  });

  @override
  ConsumerState<DepartmentAttendanceDetailScreen> createState() =>
      _DepartmentAttendanceDetailScreenState();
}

class _DepartmentAttendanceDetailScreenState
    extends ConsumerState<DepartmentAttendanceDetailScreen> {
  TrendPeriod _selectedPeriod = TrendPeriod.today;

  Color _getDepartmentColor(String dept) {
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
        return Colors.black;
      case 'CSBS':
      case 'IT':
      case 'INFORMATION TECHNOLOGY':
        return Colors.orange;
      default:
        if (dept.toUpperCase().contains('CSE')) return Colors.blue;
        if (dept.toUpperCase().contains('AIDS')) return Colors.purple;
        if (dept.toUpperCase().contains('MECH')) return Colors.green;
        if (dept.toUpperCase().contains('ECE')) return Colors.red;
        if (dept.toUpperCase().contains('MBA')) return Colors.black;
        if (dept.toUpperCase().contains('CSBS') ||
            dept.toUpperCase() == 'IT' ||
            dept.toUpperCase().contains('INFORMATION TECHNOLOGY')) {
          return Colors.orange;
        }
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allStaff = ref.watch(staffProvider);
    final deptStaff = allStaff
        .where((s) => s.dept == widget.departmentName)
        .toList();

    final todaysRecords = ref.watch(todaysAttendanceProvider);

    int presentCount = 0;
    int absentCount = 0;

    for (var staff in deptStaff) {
      final record = todaysRecords
          .where((r) => r.staffId == staff.id)
          .lastOrNull;
      if (record == null || record.status == AttendanceStatus.absent) {
        absentCount++;
      } else if (record.status == AttendanceStatus.present) {
        presentCount++;
      } else if (record.status == AttendanceStatus.leave) {
        absentCount++; // Assuming leave means not present, prompt: "Present Today", "Absent Today"
      }
    }

    final totalStaff = deptStaff.length;
    final Map<String, dynamic> deptStats = {
      'total': totalStaff,
      'present': presentCount,
      'absent': absentCount,
      'percent': totalStaff == 0 ? 0.0 : (presentCount / totalStaff) * 100.0,
    };

    final deptColor = _getDepartmentColor(widget.departmentName);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${widget.departmentName} Department'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(deptStats, deptColor),
              SizedBox(height: 32),
              _buildTrendSection(deptColor),
              SizedBox(height: 32),
              _buildStaffList(deptStaff, todaysRecords),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(Map<String, dynamic> stats, Color color) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCol('Total Staff', stats['total'].toString()),
          _buildStatCol('Present Today', stats['present'].toString()),
          _buildStatCol('Absent Today', stats['absent'].toString()),
          _buildStatCol(
            'Attendance',
            '${stats['percent'].toStringAsFixed(1)}%',
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendSection(Color deptColor) {
    final args = DepartmentTrendArgs(
      department: widget.departmentName,
      period: _selectedPeriod,
    );
    final trendData = ref.watch(departmentTrendProvider(args));

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(data: trendData, lineColor: deptColor),
            ),
          ),
        ],
      ),
    );
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
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffList(
    List<Staff> deptStaff,
    List<AttendanceRecord> todaysRecords,
  ) {
    final allAttendanceForStaff = ref.watch(attendanceProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Staff List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: deptStaff.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Theme.of(context).dividerColor),
            itemBuilder: (context, index) {
              final staff = deptStaff[index];
              final record = todaysRecords
                  .where((r) => r.staffId == staff.id)
                  .lastOrNull;
              final status = record == null
                  ? AttendanceStatus.absent
                  : record.status;

              int presentDays = 0;
              final personalRecords = allAttendanceForStaff
                  .where((r) => r.staffId == staff.id)
                  .toList();
              final groupedByDate = <DateTime, AttendanceStatus>{};
              for (final r in personalRecords) {
                groupedByDate[DateTime(r.date.year, r.date.month, r.date.day)] =
                    r.status;
              }
              int totalDays = groupedByDate.length;
              for (final st in groupedByDate.values) {
                if (st == AttendanceStatus.present) {
                  presentDays++;
                }
              }
              double overallPercent = totalDays == 0
                  ? 0
                  : (presentDays / totalDays) * 100;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(staff.name.substring(0, 1).toUpperCase()),
                ),
                title: Text(
                  staff.name,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(staff.role),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.displayName,
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${overallPercent.toStringAsFixed(0)}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    if (status == AttendanceStatus.present) return AppTheme.success;
    if (status == AttendanceStatus.leave) return AppTheme.warning;
    return Theme.of(context).colorScheme.error;
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  LineChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final pathGradient = Path();

    final maxVal = 100.0;
    final minVal = 0.0;
    final range = maxVal - minVal;

    final width = size.width;
    final height = size.height;

    double xOffset = data.length > 1 ? width / (data.length - 1) : width;

    final path = Path();

    pathGradient.moveTo(0, height);

    for (int i = 0; i < data.length; i++) {
      double x = i * xOffset;
      if (data.length == 1) {
        x = width / 2;
      }
      double yVal = data[i];
      if (yVal > 100) yVal = 100;
      if (yVal < 0) yVal = 0;

      double y = height - ((yVal / range) * height);

      if (i == 0) {
        path.moveTo(x, y);
        if (data.length > 1) {
          pathGradient.lineTo(x, y);
        }
      } else {
        path.lineTo(x, y);
        pathGradient.lineTo(x, y);
      }
    }

    if (data.length > 1) {
      pathGradient.lineTo(width, height);
      pathGradient.close();

      final paintFill = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.3),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(0, 0, width, height));

      canvas.drawPath(pathGradient, paintFill);
    }

    canvas.drawPath(path, paintLine);

    for (int i = 0; i < data.length; i++) {
      double x = i * xOffset;
      if (data.length == 1) x = width / 2;
      double yVal = data[i];
      if (yVal > 100) yVal = 100;
      if (yVal < 0) yVal = 0;

      double y = height - ((yVal / range) * height);
      canvas.drawCircle(Offset(x, y), 5, paintDot);

      final dotInner = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 2.5, dotInner);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
