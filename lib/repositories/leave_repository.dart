import 'package:sample_app/models/leave_request.dart';
import 'package:sample_app/data/remote/firestore_service.dart';
import 'package:sample_app/core/enums.dart';

class LeaveRepository {
  final _service = FirestoreService.instance;
  final String _collection = 'leave_requests';

  Stream<List<LeaveRequestModel>> watchLeaveRequests() {
    return _service.collectionStream<LeaveRequestModel>(
      path: _collection,
      builder: (doc) => LeaveRequestModel.fromFirestore(doc),
    );
  }

  Future<void> addLeave(LeaveRequestModel request) async {
    await _service.setData(
      path: '$_collection/${request.id}',
      data: request.toFirestore(),
    );
  }

  Future<void> approveLeave(String id) async {
    await _service.updateData(
      path: '$_collection/$id',
      data: {'status': LeaveStatus.approved.name},
    );
  }

  Future<void> rejectLeave(String id) async {
    await _service.updateData(
      path: '$_collection/$id',
      data: {'status': LeaveStatus.rejected.name},
    );
  }
}
