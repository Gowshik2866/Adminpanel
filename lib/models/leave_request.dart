import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/staff.dart';

class LeaveRequestModel {
  final String id;
  final Staff staff;
  final LeaveType leaveType;
  final String
  dateRange; // Kept as string for simplicity to match UI, or separate start/end dates.
  final DateTime startDate;
  final DateTime endDate;
  final LeaveStatus status;
  final String reason;

  const LeaveRequestModel({
    required this.id,
    required this.staff,
    required this.leaveType,
    required this.dateRange,
    required this.startDate,
    required this.endDate,
    this.status = LeaveStatus.pending,
    this.reason = '',
  });

  String get initials {
    if (staff.name.isEmpty) return '?';
    final parts = staff.name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return staff.name[0].toUpperCase();
  }

  LeaveRequestModel copyWith({
    String? id,
    Staff? staff,
    LeaveType? leaveType,
    String? dateRange,
    DateTime? startDate,
    DateTime? endDate,
    LeaveStatus? status,
    String? reason,
  }) {
    return LeaveRequestModel(
      id: id ?? this.id,
      staff: staff ?? this.staff,
      leaveType: leaveType ?? this.leaveType,
      dateRange: dateRange ?? this.dateRange,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      reason: reason ?? this.reason,
    );
  }
}
