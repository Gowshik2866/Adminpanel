import 'package:sample_app/core/enums.dart';
import 'package:sample_app/core/firestore/firestore_extensions.dart';
import 'package:sample_app/features/staff/domain/entities/staff.dart';

class StaffModel extends Staff {
  const StaffModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.role,
    required super.dept,
    required super.employmentType,
    required super.status,
    required super.joiningDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      'dept': dept,
      'employmentType': employmentType.name,
      'status': status.name,
      'joiningDate': joiningDate.toTimestamp(),
    };
  }

  factory StaffModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StaffModel(
      id: documentId,
      name: map.safeString('name'),
      email: map.safeString('email'),
      phone: map['phone'] as String?,
      role: map.safeString('role', defaultValue: 'Staff'),
      dept: map.safeString('dept', defaultValue: 'General'),
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.name == map['employmentType'],
        orElse: () => EmploymentType.fullTime,
      ),
      status: StaffStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StaffStatus.active,
      ),
      joiningDate: map.safeDateTime('joiningDate') ?? DateTime.now(),
    );
  }

  factory StaffModel.fromEntity(Staff staff) {
    return StaffModel(
      id: staff.id,
      name: staff.name,
      email: staff.email,
      phone: staff.phone,
      role: staff.role,
      dept: staff.dept,
      employmentType: staff.employmentType,
      status: staff.status,
      joiningDate: staff.joiningDate,
    );
  }
}
