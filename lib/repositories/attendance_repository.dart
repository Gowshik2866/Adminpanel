import 'package:sample_app/models/attendance.dart';
import 'package:sample_app/data/remote/firestore_service.dart';

class AttendanceRepository {
  final _service = FirestoreService.instance;
  final String _collection = 'attendance';

  Stream<List<AttendanceRecord>> watchAttendance() {
    return _service.collectionStream<AttendanceRecord>(
      path: _collection,
      builder: (doc) => AttendanceRecord.fromFirestore(doc),
    );
  }

  Future<void> markAttendance(AttendanceRecord record) async {
    await _service.setData(
      path: '$_collection/${record.id}',
      data: record.toFirestore(),
    );
  }

  Future<void> updateAttendance(AttendanceRecord record) async {
    await _service.updateData(
      path: '$_collection/${record.id}',
      data: record.toFirestore(),
    );
  }
}
