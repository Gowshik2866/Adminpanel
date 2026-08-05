import 'package:sample_app/features/attendance/domain/entities/attendance.dart';

abstract class AttendanceRepository {
  Stream<List<AttendanceRecord>> getAttendanceStream();
  Future<void> saveAttendance(AttendanceRecord record);
  Future<void> saveAttendanceBatch(List<AttendanceRecord> records);
  Future<void> updateAttendance(AttendanceRecord record);
}
