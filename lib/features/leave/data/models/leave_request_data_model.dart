import 'package:sample_app/core/enums.dart';
import 'package:sample_app/core/firestore/firestore_extensions.dart';
import 'package:sample_app/features/leave/domain/entities/leave_request.dart';
import 'package:sample_app/features/staff/domain/entities/staff.dart';

class LeaveRequestDataModel extends LeaveRequestModel {
  const LeaveRequestDataModel({
    required super.id,
    required super.staff,
    required super.leaveType,
    required super.dateRange,
    required super.startDate,
    required super.endDate,
    super.status,
    super.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staffId': staff.id,
      'staffName': staff.name,
      'staffDept': staff.dept,
      'leaveType': leaveType.name,
      'dateRange': dateRange,
      'startDate': startDate.toTimestamp(),
      'endDate': endDate.toTimestamp(),
      'status': status.name,
      'reason': reason,
    };
  }

  factory LeaveRequestDataModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LeaveRequestDataModel(
      id: documentId,
      // We recreate a partial Staff object here for UI rendering
      staff: Staff(
        id: map.safeString('staffId'),
        name: map.safeString('staffName'),
        email: '',
        role: 'Staff',
        dept: map.safeString('staffDept'),
        employmentType: EmploymentType.fullTime,
        status: StaffStatus.active,
        joiningDate: DateTime.now(),
      ),
      leaveType: LeaveType.values.firstWhere(
        (e) => e.name == map['leaveType'],
        orElse: () => LeaveType.casual,
      ),
      dateRange: map.safeString('dateRange'),
      startDate: map.safeDateTime('startDate') ?? DateTime.now(),
      endDate: map.safeDateTime('endDate') ?? DateTime.now(),
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LeaveStatus.pending,
      ),
      reason: map.safeString('reason'),
    );
  }

  factory LeaveRequestDataModel.fromEntity(LeaveRequestModel model) {
    return LeaveRequestDataModel(
      id: model.id,
      staff: model.staff,
      leaveType: model.leaveType,
      dateRange: model.dateRange,
      startDate: model.startDate,
      endDate: model.endDate,
      status: model.status,
      reason: model.reason,
    );
  }
}
