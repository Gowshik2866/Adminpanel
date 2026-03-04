import 'package:sample_app/core/enums.dart';

class AttendanceRecord {
  final String id;
  final String staffId;
  final DateTime date;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.id,
    required this.staffId,
    required this.date,
    required this.status,
  });

  AttendanceRecord copyWith({
    String? id,
    String? staffId,
    DateTime? date,
    AttendanceStatus? status,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
