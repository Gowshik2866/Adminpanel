import 'package:sample_app/core/enums.dart';

class Staff {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String dept;
  final EmploymentType employmentType;
  final StaffStatus status;
  final DateTime joiningDate;

  const Staff({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.dept,
    required this.employmentType,
    required this.status,
    required this.joiningDate,
  });

  Staff copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? dept,
    EmploymentType? employmentType,
    StaffStatus? status,
    DateTime? joiningDate,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      dept: dept ?? this.dept,
      employmentType: employmentType ?? this.employmentType,
      status: status ?? this.status,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
}
