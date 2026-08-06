import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/attendance.dart';
import 'package:sample_app/repositories/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final attendanceProvider = StreamProvider<List<AttendanceRecord>>((ref) {
  return ref.read(attendanceRepositoryProvider).watchAttendance();
});
