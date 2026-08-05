import 'package:sample_app/features/attendance/data/models/attendance_model.dart';
import 'package:sample_app/features/attendance/data/sources/attendance_remote_data_source.dart';
import 'package:sample_app/features/attendance/domain/entities/attendance.dart';
import 'package:sample_app/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<AttendanceRecord>> getAttendanceStream() {
    return remoteDataSource.getAttendanceStream();
  }

  @override
  Future<void> saveAttendance(AttendanceRecord record) {
    return remoteDataSource.saveAttendance(AttendanceModel.fromEntity(record));
  }

  @override
  Future<void> saveAttendanceBatch(List<AttendanceRecord> records) {
    final models = records.map((r) => AttendanceModel.fromEntity(r)).toList();
    return remoteDataSource.saveAttendanceBatch(models);
  }

  @override
  Future<void> updateAttendance(AttendanceRecord record) {
    return remoteDataSource.updateAttendance(AttendanceModel.fromEntity(record));
  }
}
