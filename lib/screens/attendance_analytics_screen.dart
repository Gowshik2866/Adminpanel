import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/staff.dart';
import 'package:sample_app/providers/attendance_provider.dart';
import 'package:sample_app/providers/holiday_provider.dart';
import 'package:sample_app/providers/staff_provider.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/section_title.dart';

// ─── Filter enum ─────────────────────────────────────────────────────────────

enum AttendanceFilter { all, present, absent, late, holiday }

extension AttendanceFilterExt on AttendanceFilter {
  String get label {
    switch (this) {
      case AttendanceFilter.all:
        return 'All';
      case AttendanceFilter.present:
        return 'Present';
      case AttendanceFilter.absent:
        return 'Absent';
      case AttendanceFilter.late:
        return 'Late / Leave';
      case AttendanceFilter.holiday:
        return 'On Holiday';
    }
  }

  IconData get icon {
    switch (this) {
      case AttendanceFilter.all:
        return Icons.people_rounded;
      case AttendanceFilter.present:
        return Icons.how_to_reg_rounded;
      case AttendanceFilter.absent:
        return Icons.person_off_rounded;
      case AttendanceFilter.late:
        return Icons.access_time_rounded;
      case AttendanceFilter.holiday:
        return Icons.holiday_village_rounded;
    }
  }

  Color color(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (this) {
      case AttendanceFilter.all:
        return cs.primary;
      case AttendanceFilter.present:
        return AppTheme.success;
      case AttendanceFilter.absent:
        return cs.error;
      case AttendanceFilter.late:
        return AppTheme.warning;
      case AttendanceFilter.holiday:
        return AppTheme.success;
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AttendanceAnalyticsScreen extends ConsumerStatefulWidget {
  final AttendanceFilter initialFilter;

  const AttendanceAnalyticsScreen({
    super.key,
    this.initialFilter = AttendanceFilter.all,
  });

  @override
  ConsumerState<AttendanceAnalyticsScreen> createState() =>
      _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState
    extends ConsumerState<AttendanceAnalyticsScreen> {
  late AttendanceFilter _activeFilter;

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialFilter;
  }

  // ── Attendance resolution ──────────────────────────────────────────────────

  AttendanceFilter _resolveStatus(
    String staffId,
    String dept,
    List<dynamic> todayRecords,
    dynamic holidayNotifier,
  ) {
    final today = DateTime.now();
    if (holidayNotifier.isHoliday(today, dept)) return AttendanceFilter.holiday;

    final record = todayRecords.where((r) => r.staffId == staffId).firstOrNull;

    if (record == null) return AttendanceFilter.absent;

    switch (record.status as AttendanceStatus) {
      case AttendanceStatus.present:
        return AttendanceFilter.present;
      case AttendanceStatus.absent:
        return AttendanceFilter.absent;
      case AttendanceStatus.leave:
        return AttendanceFilter.late;
      case AttendanceStatus.holiday:
        return AttendanceFilter.holiday;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final activeStaff = ref.watch(activeStaffProvider);
    final todayRecords = ref.watch(todaysAttendanceProvider);
    final holidayNotifier = ref.watch(holidayProvider.notifier);

    // ── Compute live counts ──────────────────────────────────────────────────
    int present = 0, absent = 0, late = 0, holiday = 0;

    final List<({Staff staff, AttendanceFilter status})> staffWithStatus = [];

    for (final staff in activeStaff) {
      final status = _resolveStatus(
        staff.id,
        staff.dept,
        todayRecords,
        holidayNotifier,
      );
      staffWithStatus.add((staff: staff, status: status));
      switch (status) {
        case AttendanceFilter.present:
          present++;
          break;
        case AttendanceFilter.absent:
          absent++;
          break;
        case AttendanceFilter.late:
          late++;
          break;
        case AttendanceFilter.holiday:
          holiday++;
          break;
        case AttendanceFilter.all:
          break;
      }
    }

    final total = activeStaff.length;
    final tracked = present + absent + late + holiday;
    final overallPct = tracked == 0 ? 0.0 : present / tracked;

    // ── Filtered staff list ──────────────────────────────────────────────────
    final filtered = _activeFilter == AttendanceFilter.all
        ? staffWithStatus
        : staffWithStatus.where((e) => e.status == _activeFilter).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onSurface,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: SectionTitle(
                      title: 'Attendance Analytics',
                      subtitle:
                          'Live attendance breakdown — updates in real time.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary cards ──────────────────────────────────────
                    _SummaryRow(
                      total: total,
                      present: present,
                      absent: absent,
                      late: late,
                      overallPct: overallPct,
                    ),

                    const SizedBox(height: 28),

                    // ── Pie chart + breakdown side by side ─────────────────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 680;
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _PieSection(
                                  present: present.toDouble(),
                                  absent: absent.toDouble(),
                                  late: late.toDouble(),
                                  tracked: tracked.toDouble(),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 4,
                                child: _BreakdownSection(
                                  present: present,
                                  absent: absent,
                                  late: late,
                                  holiday: holiday,
                                  total: total,
                                  tracked: tracked,
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _PieSection(
                              present: present.toDouble(),
                              absent: absent.toDouble(),
                              late: late.toDouble(),
                              tracked: tracked.toDouble(),
                            ),
                            const SizedBox(height: 20),
                            _BreakdownSection(
                              present: present,
                              absent: absent,
                              late: late,
                              holiday: holiday,
                              total: total,
                              tracked: tracked,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── Filter chips ───────────────────────────────────────
                    Text(
                      'Filter by Status',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AttendanceFilter.values.map((f) {
                        final isActive = f == _activeFilter;
                        final fColor = f.color(context);
                        return GestureDetector(
                          onTap: () => setState(() => _activeFilter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? fColor.withValues(alpha: 0.15)
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: isActive ? fColor : theme.dividerColor,
                                width: isActive ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  f.icon,
                                  size: 15,
                                  color: isActive
                                      ? fColor
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  f.label,
                                  style: TextStyle(
                                    color: isActive
                                        ? fColor
                                        : colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (isActive) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: fColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${filtered.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ── Staff list ─────────────────────────────────────────
                    if (filtered.isEmpty)
                      _EmptyState(filter: _activeFilter)
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = constraints.maxWidth > 900
                              ? 3
                              : (constraints.maxWidth > 580 ? 2 : 1);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: 88,
                                ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final item = filtered[i];
                              return _StaffAttendanceTile(
                                staff: item.staff,
                                status: item.status,
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary Row ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final int total, present, absent, late;
  final double overallPct;

  const _SummaryRow({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.overallPct,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;
    final divider = Theme.of(context).dividerColor;

    final items = [
      (
        label: 'Total Staff',
        value: '$total',
        icon: Icons.groups_rounded,
        bg: cs.primaryContainer,
        ic: cs.primary,
        accent: cs.primary,
      ),
      (
        label: 'Present',
        value: '$present',
        icon: Icons.how_to_reg_rounded,
        bg: AppTheme.success.withValues(alpha: 0.12),
        ic: AppTheme.success,
        accent: AppTheme.success,
      ),
      (
        label: 'Absent',
        value: '$absent',
        icon: Icons.person_off_rounded,
        bg: cs.errorContainer,
        ic: cs.error,
        accent: cs.error,
      ),
      (
        label: 'Late / Leave',
        value: '$late',
        icon: Icons.access_time_rounded,
        bg: AppTheme.warning.withValues(alpha: 0.12),
        ic: AppTheme.warning,
        accent: AppTheme.warning,
      ),
      (
        label: 'Overall Rate',
        value: '${(overallPct * 100).toStringAsFixed(0)}%',
        icon: Icons.donut_large_rounded,
        bg: cs.primaryContainer,
        ic: cs.primary,
        accent: cs.primary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 720;
        if (wide) {
          return Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _SummaryCard(
                    label: items[i].label,
                    value: items[i].value,
                    icon: items[i].icon,
                    bg: items[i].bg,
                    ic: items[i].ic,
                    accent: items[i].accent,
                    cardColor: cardColor,
                    divider: divider,
                  ),
                ),
                if (i < items.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        }
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.0,
          children: items
              .map(
                (item) => _SummaryCard(
                  label: item.label,
                  value: item.value,
                  icon: item.icon,
                  bg: item.bg,
                  ic: item.ic,
                  accent: item.accent,
                  cardColor: cardColor,
                  divider: divider,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, ic, accent, cardColor, divider;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bg,
    required this.ic,
    required this.accent,
    required this.cardColor,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ic, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pie chart section ────────────────────────────────────────────────────────

class _PieSection extends StatelessWidget {
  final double present, absent, late, tracked;

  const _PieSection({
    required this.present,
    required this.absent,
    required this.late,
    required this.tracked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final presentPct = tracked == 0 ? 0.0 : (present / tracked * 100);
    final absentPct = tracked == 0 ? 0.0 : (absent / tracked * 100);
    final latePct = tracked == 0 ? 0.0 : (late / tracked * 100);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall System Attendance Rate',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Live breakdown — updates dynamically.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _PieChartPainter(
                  present: present,
                  absent: absent,
                  late: late,
                  trackColor: theme.dividerColor,
                  presentColor: AppTheme.success,
                  absentColor: cs.error,
                  lateColor: AppTheme.warning,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${presentPct.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'PRESENT',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(
                color: AppTheme.success,
                label: 'Present',
                pct: '${presentPct.toStringAsFixed(1)}%',
              ),
              _LegendItem(
                color: cs.error,
                label: 'Absent',
                pct: '${absentPct.toStringAsFixed(1)}%',
              ),
              _LegendItem(
                color: AppTheme.warning,
                label: 'Late',
                pct: '${latePct.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label, pct;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          pct,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ─── Breakdown section ────────────────────────────────────────────────────────

class _BreakdownSection extends StatelessWidget {
  final int present, absent, late, holiday, total, tracked;

  const _BreakdownSection({
    required this.present,
    required this.absent,
    required this.late,
    required this.holiday,
    required this.total,
    required this.tracked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Percentage Breakdown',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _BarRow(
            label: 'Present',
            count: present,
            total: tracked,
            color: AppTheme.success,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 16),
          _BarRow(
            label: 'Absent',
            count: absent,
            total: tracked,
            color: cs.error,
            icon: Icons.highlight_off_rounded,
          ),
          const SizedBox(height: 16),
          _BarRow(
            label: 'Late / Leave',
            count: late,
            total: tracked,
            color: AppTheme.warning,
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: 16),
          _BarRow(
            label: 'On Holiday',
            count: holiday,
            total: tracked,
            color: cs.primary,
            icon: Icons.holiday_village_rounded,
          ),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tracked / Total',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$tracked / $total',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  final IconData icon;

  const _BarRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = total == 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    final pctText =
        '${total == 0 ? 0 : (count / total * 100).toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 44,
              child: Text(
                pctText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 7,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  height: 7,
                  width: constraints.maxWidth * pct,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─── Staff attendance tile ────────────────────────────────────────────────────

class _StaffAttendanceTile extends StatelessWidget {
  final Staff staff;
  final AttendanceFilter status;

  const _StaffAttendanceTile({required this.staff, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final color = status.color(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primaryContainer,
            child: Text(
              staff.name[0].toUpperCase(),
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  staff.name,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${staff.role} · ${staff.dept}',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, color: color, size: 12),
                const SizedBox(width: 4),
                Text(
                  status.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AttendanceFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              filter.icon,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 14),
            Text(
              'No staff with status "${filter.label}" today.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pie chart painter ────────────────────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  final double present, absent, late;
  final Color trackColor, presentColor, absentColor, lateColor;

  const _PieChartPainter({
    required this.present,
    required this.absent,
    required this.late,
    required this.trackColor,
    required this.presentColor,
    required this.absentColor,
    required this.lateColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    const strokeWidth = 26.0;
    const gap = 0.05;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final total = present + absent + late;
    if (total <= 0) return;

    final slices = [
      (val: present, color: presentColor),
      (val: absent, color: absentColor),
      (val: late, color: lateColor),
    ];

    double start = -math.pi / 2;
    for (final s in slices) {
      final sweep = (s.val / total) * 2 * math.pi - gap;
      if (sweep > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          sweep,
          false,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
        );
      }
      start += (s.val / total) * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter old) =>
      old.present != present || old.absent != absent || old.late != late;
}
