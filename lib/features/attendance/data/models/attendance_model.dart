import 'package:sample_app/core/enums.dart';
import 'package:sample_app/core/firestore/firestore_extensions.dart';
import 'package:sample_app/features/attendance/domain/entities/attendance.dart';

class AttendanceModel extends AttendanceRecord {
  const AttendanceModel({
    required super.id,
    required super.staffId,
    required super.date,
    required super.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staffId': staffId,
      'date': date.toTimestamp(),
      'status': status.name,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AttendanceModel(
      id: documentId,
      staffId: map.safeString('staffId'),
      date: map.safeDateTime('date') ?? DateTime.now(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
    );
  }

  factory AttendanceModel.fromEntity(AttendanceRecord entity) {
    return AttendanceModel(
      id: entity.id,
      staffId: entity.staffId,
      date: entity.date,
      status: entity.status,
    );
  }
}
