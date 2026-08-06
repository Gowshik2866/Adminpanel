import 'package:cloud_firestore/cloud_firestore.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'dept': dept,
      'employmentType': employmentType.name,
      'status': status.name,
      'joiningDate': joiningDate.toIso8601String(),
    };
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      dept: json['dept'] as String,
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.name == json['employmentType'],
        orElse: () => EmploymentType.fullTime,
      ),
      status: StaffStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StaffStatus.active,
      ),
      joiningDate: DateTime.parse(json['joiningDate'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'dept': dept,
      'employmentType': employmentType.name,
      'status': status.name,
      'joiningDate': Timestamp.fromDate(joiningDate),
    };
  }

  factory Staff.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Staff(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String?,
      role: data['role'] as String? ?? '',
      dept: data['dept'] as String? ?? '',
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.name == data['employmentType'],
        orElse: () => EmploymentType.fullTime,
      ),
      status: StaffStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => StaffStatus.active,
      ),
      joiningDate:
          (data['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Staff &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          role == other.role &&
          dept == other.dept &&
          employmentType == other.employmentType &&
          status == other.status &&
          joiningDate == other.joiningDate;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      role.hashCode ^
      dept.hashCode ^
      employmentType.hashCode ^
      status.hashCode ^
      joiningDate.hashCode;
}
