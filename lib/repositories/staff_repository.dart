import 'package:sample_app/models/staff.dart';
import 'package:sample_app/data/remote/firestore_service.dart';

class StaffRepository {
  final _service = FirestoreService.instance;
  final String _collection = 'staff';

  Stream<List<Staff>> watchStaff() {
    return _service.collectionStream<Staff>(
      path: _collection,
      builder: (doc) => Staff.fromFirestore(doc),
    );
  }

  Future<void> addStaff(Staff staff) async {
    await _service.setData(
      path: '$_collection/${staff.id}',
      data: staff.toFirestore(),
    );
  }

  Future<void> updateStaff(Staff staff) async {
    await _service.updateData(
      path: '$_collection/${staff.id}',
      data: staff.toFirestore(),
    );
  }

  Future<void> deleteStaff(String id) async {
    await _service.deleteData(path: '$_collection/$id');
  }
}
