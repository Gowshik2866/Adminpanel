import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/leave_request.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/empty_state_view.dart';
import 'package:sample_app/providers/leave_provider.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/screen/holiday_details_screen.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const double _kMaxContentWidth = 1100.0;
const double _kContentPaddingH = 24.0;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class LeaveRequestsScreen extends ConsumerStatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  ConsumerState<LeaveRequestsScreen> createState() =>
      _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends ConsumerState<LeaveRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String _searchQuery = '';
  String _selectedDept = 'Departments';
  String _selectedPeriod = 'This Week';
  String _selectedPriority = 'Priority';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── computed ──────────────────────────────────────────────────────────────

  List<LeaveRequestModel> _filtered(List<LeaveRequestModel> requests) {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return requests;
    return requests
        .where(
          (r) =>
              r.staff.name.toLowerCase().contains(q) ||
              r.staff.role.toLowerCase().contains(q),
        )
        .toList();
  }

  // ── actions ───────────────────────────────────────────────────────────────

  void _approve(String id, String name) {
    ref.read(leaveProvider.notifier).approveLeave(id);
    _showSnack("Approved $name's request", AppTheme.success);
  }

  void _reject(String id, String name) {
    ref.read(leaveProvider.notifier).rejectLeave(id);
    _showSnack("Rejected $name's request", Theme.of(context).colorScheme.error);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetail(LeaveRequestModel req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          req.staff.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.badge_outlined,
              text: '${req.staff.role} • ${req.staff.id}',
            ),
            SizedBox(height: 8),
            _DetailRow(
              icon: Icons.event_note_rounded,
              text: req.leaveType.displayName,
            ),
            SizedBox(height: 8),
            _DetailRow(icon: Icons.calendar_today_rounded, text: req.dateRange),
            SizedBox(height: 8),
            _DetailRow(
              icon: Icons.chat_bubble_outline,
              text: req.reason.isEmpty ? 'No reason provided' : req.reason,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close')),
        ],
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pendingLeaves = ref.watch(pendingLeavesProvider);
    final leaves = ref.watch(leaveProvider);
    final filtered = _filtered(leaves);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header — full width with constrained inner content
          _PageHeader(pendingCount: pendingLeaves.length),

          // Tabs — full width
          _TabSection(controller: _tabController),

          // Constrained scrollable body
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search + Filters
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        _kContentPaddingH,
                        24,
                        _kContentPaddingH,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar
                          TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Search staff name...',
                              hintStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Filter row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterDropdown(
                                  value: _selectedDept,
                                  items: const [
                                    'Departments',
                                    'CSE',
                                    'ECE',
                                    'MECH',
                                    'IT',
                                    'AI&DS',
                                    'CIVIL',
                                  ],
                                  onChanged: (v) => setState(
                                    () => _selectedDept = v ?? _selectedDept,
                                  ),
                                ),
                                SizedBox(width: 8),
                                _FilterDropdown(
                                  value: _selectedPeriod,
                                  items: const [
                                    'This Week',
                                    'Today',
                                    'This Month',
                                    'Last Month',
                                  ],
                                  onChanged: (v) => setState(
                                    () =>
                                        _selectedPeriod = v ?? _selectedPeriod,
                                  ),
                                ),
                                SizedBox(width: 8),
                                _FilterDropdown(
                                  value: _selectedPriority,
                                  items: const ['Priority', 'A-Z', 'Z-A'],
                                  onChanged: (v) => setState(
                                    () => _selectedPriority =
                                        v ?? _selectedPriority,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // Summary strip
                          _SummaryStrip(requests: leaves),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // ── Leave Requests tab ─────────────────────────
                          filtered.isEmpty
                              ? const EmptyStateView(
                                  message: 'No leave requests found.',
                                  icon: Icons.event_busy_rounded,
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.fromLTRB(
                                    _kContentPaddingH,
                                    16,
                                    _kContentPaddingH,
                                    32,
                                  ),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, _) =>
                                      SizedBox(height: 16),
                                  itemBuilder: (_, i) {
                                    final req = filtered[i];
                                    return _RequestCard(
                                      data: req,
                                      onApprove: () =>
                                          _approve(req.id, req.staff.name),
                                      onReject: () =>
                                          _reject(req.id, req.staff.name),
                                      onView: () => _showDetail(req),
                                    );
                                  },
                                ),

                          // ── OD Requests tab ────────────────────────────
                          const EmptyStateView(
                            message: 'No OD requests found.',
                            icon: Icons.work_off_rounded,
                          ),

                          // ── Holiday Announcements tab ──────────────────
                          const HolidayDetailsScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Sub-widgets
// ===========================================================================

// ---------------------------------------------------------------------------
// Page header
// ---------------------------------------------------------------------------
class _PageHeader extends StatelessWidget {
  final int pendingCount;
  const _PageHeader({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              _kContentPaddingH,
              16,
              _kContentPaddingH,
              16,
            ),
            child: Row(
              children: [
                _IconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () {}),
                SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Pending Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (pendingCount > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$pendingCount',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _IconBtn(icon: Icons.notifications_outlined, onTap: () {}),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).cardColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small square icon button
// ---------------------------------------------------------------------------
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab bar
// ---------------------------------------------------------------------------
class _TabSection extends StatelessWidget {
  final TabController controller;
  const _TabSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
          child: TabBar(
            controller: controller,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Leave Requests'),
              Tab(text: 'OD Requests'),
              Tab(text: 'Holiday Announcements'),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pill-shaped filter dropdown
// ---------------------------------------------------------------------------
class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary strip
// ---------------------------------------------------------------------------
class _SummaryStrip extends StatelessWidget {
  final List<LeaveRequestModel> requests;
  const _SummaryStrip({required this.requests});

  @override
  Widget build(BuildContext context) {
    final pending = requests
        .where((r) => r.status == LeaveStatus.pending)
        .length;
    final approved = requests
        .where((r) => r.status == LeaveStatus.approved)
        .length;
    final rejected = requests
        .where((r) => r.status == LeaveStatus.rejected)
        .length;

    return Row(
      children: [
        _SummaryChip(label: 'Pending', count: pending, color: AppTheme.warning),
        SizedBox(width: 8),
        _SummaryChip(
          label: 'Approved',
          count: approved,
          color: AppTheme.success,
        ),
        SizedBox(width: 8),
        _SummaryChip(
          label: 'Rejected',
          count: rejected,
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6),
          Text(
            '$label ($count)',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Request card  ← PRIMARY FIX AREA
// ---------------------------------------------------------------------------
class _RequestCard extends StatefulWidget {
  final LeaveRequestModel data;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _RequestCard({
    required this.data,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _hovered = false;

  static const List<Color> _bgPalette = [
    Color(0xFFDBEAFE),
    Color(0xFFD1FAE5),
    Color(0xFFFEF3C7),
    Color(0xFFFCE7F3),
  ];
  static const List<Color> _fgPalette = [
    Color(0xFF1D4ED8),
    Color(0xFF065F46),
    Color(0xFF92400E),
    Color(0xFF9D174D),
  ];

  Color get _avatarBg {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Theme.of(context).colorScheme.primaryContainer
        : _bgPalette[widget.data.initials.hashCode.abs() % _bgPalette.length];
  }

  Color get _avatarFg {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : _fgPalette[widget.data.initials.hashCode.abs() % _fgPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.data;
    final isPending = req.status == LeaveStatus.pending;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                // ignore: deprecated_member_use
                ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
                : Theme.of(context).dividerColor,
            width: _hovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.04),
              blurRadius: _hovered ? 20 : 8,
              offset: Offset(0, _hovered ? 8 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Avatar + Employee info + Status badge ───────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _avatarBg,
                    child: Text(
                      req.initials,
                      style: TextStyle(
                        color: _avatarFg,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.staff.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${req.staff.role}  •  ${req.staff.id}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  _StatusBadge(status: req.status),
                ],
              ),

              SizedBox(height: 16),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              SizedBox(height: 16),

              // ── Row 2: Leave type + Date (visually grouped) ────────────
              Row(
                children: [
                  // Leave type
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.event_note_rounded,
                      label: 'Leave Type',
                      value: req.leaveType.displayName,
                    ),
                  ),
                  // Vertical separator
                  Container(
                    width: 1,
                    height: 36,
                    color: Theme.of(context).dividerColor,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  // Date range — visually adjacent, same visual weight
                  _InfoTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: req.dateRange,
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                ],
              ),

              SizedBox(height: 16),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              SizedBox(height: 16),

              // ── Row 3: Action buttons ─────────────────────────────────
              // Approve(flex 3) | gap | Reject(flex 2) | gap | Eye(48×48)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isPending) ...[
                    Expanded(
                      flex: 3,
                      child: _ActionButton(
                        label: 'Approve',
                        icon: Icons.check_rounded,
                        filled: true,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: widget.onApprove,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _ActionButton(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        filled: false,
                        color: Theme.of(context).colorScheme.error,
                        onTap: widget.onReject,
                      ),
                    ),
                    SizedBox(width: 8),
                  ] else
                    const Spacer(),
                  // Eye button — fixed 48×48, baseline-aligned with buttons
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: _EyeButton(onTap: widget.onView),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info tile (label + value stacked, icon leading)
// ---------------------------------------------------------------------------
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------
class _StatusBadge extends StatelessWidget {
  final LeaveStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case LeaveStatus.approved:
        color = AppTheme.success;
        label = 'APPROVED';
        break;
      case LeaveStatus.rejected:
        color = Theme.of(context).colorScheme.error;
        label = 'REJECTED';
        break;
      default:
        color = AppTheme.warning;
        label = 'PENDING';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filled / outlined action button  (height fixed at 48 for alignment)
// ---------------------------------------------------------------------------
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    const textStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 13);

    return SizedBox(
      height: 48,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                textStyle: textStyle,
                shape: shape,
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                // ignore: deprecated_member_use
                side: BorderSide(color: color.withOpacity(0.5)),
                textStyle: textStyle,
                shape: shape,
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Eye / view button — fixed 48×48
// ---------------------------------------------------------------------------
class _EyeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EyeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Center(
          child: Icon(
            Icons.remove_red_eye_outlined,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail dialog row
// ---------------------------------------------------------------------------
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
