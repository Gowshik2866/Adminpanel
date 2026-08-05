import 'package:sample_app/core/firestore/firestore_constants.dart';
import 'package:sample_app/core/firestore/firestore_service.dart';
import 'package:sample_app/features/attendance/data/models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Stream<List<AttendanceModel>> getAttendanceStream();
  Future<void> saveAttendance(AttendanceModel model);
  Future<void> saveAttendanceBatch(List<AttendanceModel> models);
  Future<void> updateAttendance(AttendanceModel model);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirestoreService _firestoreService;

  AttendanceRemoteDataSourceImpl(this._firestoreService);

  @override
  Stream<List<AttendanceModel>> getAttendanceStream() {
    return _firestoreService.collectionStream<AttendanceModel>(
      path: FirestoreConstants.attendance,
      builder: (data, documentId) => AttendanceModel.fromMap(data, documentId),
    );
  }

  @override
  Future<void> saveAttendanceBatch(List<AttendanceModel> models) async {
    const int batchSize = 500;

    for (int i = 0; i < models.length; i += batchSize) {
      final end = (i + batchSize < models.length)
          ? i + batchSize
          : models.length;
      final chunk = models.sublist(i, end);

      final batch = _firestoreService.batch();
      for (final model in chunk) {
        final docRef = _firestoreService.db
            .collection(FirestoreConstants.attendance)
            .doc();
        final modelWithId = AttendanceModel.fromEntity(
          model.copyWith(id: docRef.id),
        );
        batch.set(docRef, modelWithId.toMap());
      }
      await batch.commit();
    }
  }

  @override
  Future<void> saveAttendance(AttendanceModel record) {
    return _firestoreService.addDocument(
      path: FirestoreConstants.attendance,
      data: record.toMap(),
      docId: record.id.isNotEmpty ? record.id : null,
    );
  }

  @override
  Future<void> updateAttendance(AttendanceModel record) {
    return _firestoreService.addDocument(
      path: FirestoreConstants.attendance,
      data: record.toMap(),
      docId: record.id.isNotEmpty ? record.id : null,
    );
  }
}
