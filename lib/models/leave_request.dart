import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/staff.dart';

class LeaveRequestModel {
  final String id;
  final Staff staff;
  final LeaveType leaveType;
  final String dateRange;
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
      return ''.toUpperCase();
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff': staff.toJson(),
      'leaveType': leaveType.name,
      'dateRange': dateRange,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'reason': reason,
    };
  }

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] as String,
      staff: Staff.fromJson(json['staff'] as Map<String, dynamic>),
      leaveType: LeaveType.values.firstWhere(
        (e) => e.name == json['leaveType'],
        orElse: () => LeaveType.casual,
      ),
      dateRange: json['dateRange'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LeaveStatus.pending,
      ),
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'staff': staff.toFirestore(),
      'leaveType': leaveType.name,
      'dateRange': dateRange,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'reason': reason,
    };
  }

  factory LeaveRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LeaveRequestModel(
      id: doc.id,
      staff: Staff.fromJson(data['staff'] as Map<String, dynamic>? ?? {}),
      leaveType: LeaveType.values.firstWhere(
        (e) => e.name == data['leaveType'],
        orElse: () => LeaveType.casual,
      ),
      dateRange: data['dateRange'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => LeaveStatus.pending,
      ),
      reason: data['reason'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          staff == other.staff &&
          leaveType == other.leaveType &&
          dateRange == other.dateRange &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          status == other.status &&
          reason == other.reason;

  @override
  int get hashCode =>
      id.hashCode ^
      staff.hashCode ^
      leaveType.hashCode ^
      dateRange.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      status.hashCode ^
      reason.hashCode;
}
