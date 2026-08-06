import 'package:cloud_firestore/cloud_firestore.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'date': date.toIso8601String(),
      'status': status.name,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.present,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'staffId': staffId,
      'date': Timestamp.fromDate(date),
      'status': status.name,
    };
  }

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AttendanceRecord(
      id: doc.id,
      staffId: data['staffId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AttendanceStatus.present,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          staffId == other.staffId &&
          date == other.date &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^ staffId.hashCode ^ date.hashCode ^ status.hashCode;
}
