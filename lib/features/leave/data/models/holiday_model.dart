import 'package:sample_app/core/firestore/firestore_extensions.dart';
import 'package:sample_app/features/leave/domain/entities/holiday.dart';

class HolidayModel extends Holiday {
  const HolidayModel({
    required super.id,
    required super.title,
    required super.description,
    required super.startDate,
    required super.endDate,
    required super.department,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toTimestamp(),
      'endDate': endDate.toTimestamp(),
      'department': department,
    };
  }

  factory HolidayModel.fromMap(Map<String, dynamic> map, String documentId) {
    return HolidayModel(
      id: documentId,
      title: map.safeString('title'),
      description: map.safeString('description'),
      startDate: map.safeDateTime('startDate') ?? DateTime.now(),
      endDate: map.safeDateTime('endDate') ?? DateTime.now(),
      department: map.safeString('department', defaultValue: 'All'),
    );
  }

  factory HolidayModel.fromEntity(Holiday entity) {
    return HolidayModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startDate: entity.startDate,
      endDate: entity.endDate,
      department: entity.department,
    );
  }
}
