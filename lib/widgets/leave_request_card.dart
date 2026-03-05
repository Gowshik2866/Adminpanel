import 'package:flutter/material.dart';
import 'package:sample_app/models/staff_model.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'animated_hover_card.dart';

class LeaveRequestCard extends StatelessWidget {
  final LeaveRequest data;

  const LeaveRequestCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverCard(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  data.initials,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${data.role} • ${data.employeeId}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context, data.status),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              SizedBox(width: 8),
              Text(data.leaveType),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              SizedBox(width: 8),
              Text(data.dateRange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return _statusChip("APPROVED", AppTheme.success);
      case LeaveStatus.rejected:
        return _statusChip("REJECTED", Theme.of(context).colorScheme.error);
      default:
        return _statusChip("PENDING", AppTheme.warning);
    }
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
