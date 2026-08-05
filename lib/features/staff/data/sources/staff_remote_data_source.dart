import 'package:sample_app/core/firestore/firestore_constants.dart';
import 'package:sample_app/core/firestore/firestore_service.dart';
import 'package:sample_app/features/staff/data/models/staff_model.dart';


abstract class StaffRemoteDataSource {
  Stream<List<StaffModel>> getStaffListStream();
  Future<List<StaffModel>> getStaffList();
  Future<void> addStaff(StaffModel staff);
  Future<void> updateStaff(StaffModel staff);
  Future<void> deleteStaff(String staffId);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final FirestoreService _firestoreService;

  StaffRemoteDataSourceImpl(this._firestoreService);

  @override
  Stream<List<StaffModel>> getStaffListStream() {
    return _firestoreService.collectionStream<StaffModel>(
      path: FirestoreConstants.staff,
      builder: (data, documentId) => StaffModel.fromMap(data, documentId),
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }
  
  @override
  Future<List<StaffModel>> getStaffList() {
    return _firestoreService.getCollection<StaffModel>(
      path: FirestoreConstants.staff,
      builder: (data, documentId) => StaffModel.fromMap(data, documentId),
    );
  }

  @override
  Future<void> addStaff(StaffModel staff) {
    return _firestoreService.addDocument(
      path: FirestoreConstants.staff,
      data: staff.toMap(),
      docId: staff.id.isNotEmpty ? staff.id : null,
    );
  }

  @override
  Future<void> updateStaff(StaffModel staff) {
    return _firestoreService.updateDocument(
      path: FirestoreConstants.staff,
      docId: staff.id,
      data: staff.toMap(),
    );
  }

  @override
  Future<void> deleteStaff(String staffId) {
    return _firestoreService.deleteDocument(
      path: FirestoreConstants.staff,
      docId: staffId,
    );
  }
}
