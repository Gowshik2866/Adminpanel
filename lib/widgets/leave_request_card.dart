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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  data.initials,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${data.role} • ${data.employeeId}",
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(data.status),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.event_note_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Text(data.leaveType),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Text(data.dateRange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return _statusChip("APPROVED", AppTheme.success);
      case LeaveStatus.rejected:
        return _statusChip("REJECTED", AppTheme.danger);
      default:
        return _statusChip("PENDING", AppTheme.warning);
    }
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
