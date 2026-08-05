import 'package:sample_app/core/firestore/firestore_constants.dart';
import 'package:sample_app/core/firestore/firestore_service.dart';
import 'package:sample_app/features/leave/data/models/holiday_model.dart';
import 'package:sample_app/features/leave/data/models/leave_request_data_model.dart';

abstract class LeaveRemoteDataSource {
  Stream<List<LeaveRequestDataModel>> getLeaveRequestsStream();
  Future<void> submitLeaveRequest(LeaveRequestDataModel request);
  Future<void> approveLeave(String requestId);
  Future<void> rejectLeave(String requestId);
  Future<void> deleteLeaveRequest(String requestId);

  Stream<List<HolidayModel>> getHolidaysStream();
  Future<void> addHoliday(HolidayModel holiday);
  Future<void> deleteHoliday(String holidayId);
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final FirestoreService _firestoreService;

  LeaveRemoteDataSourceImpl(this._firestoreService);

  @override
  Stream<List<LeaveRequestDataModel>> getLeaveRequestsStream() {
    return _firestoreService.collectionStream<LeaveRequestDataModel>(
      path: FirestoreConstants.leaveRequests,
      builder: (data, documentId) => LeaveRequestDataModel.fromMap(data, documentId),
      sort: (a, b) => b.startDate.compareTo(a.startDate),
    );
  }

  @override
  Future<void> submitLeaveRequest(LeaveRequestDataModel request) {
    return _firestoreService.addDocument(
      path: FirestoreConstants.leaveRequests,
      data: request.toMap(),
      docId: request.id.isNotEmpty ? request.id : null,
    );
  }

  @override
  Future<void> approveLeave(String requestId) {
    return _firestoreService.updateDocument(
      path: FirestoreConstants.leaveRequests,
      docId: requestId,
      data: {'status': 'approved'},
    );
  }

  @override
  Future<void> rejectLeave(String requestId) {
    return _firestoreService.updateDocument(
      path: FirestoreConstants.leaveRequests,
      docId: requestId,
      data: {'status': 'rejected'},
    );
  }

  @override
  Future<void> deleteLeaveRequest(String requestId) {
    return _firestoreService.deleteDocument(
      path: FirestoreConstants.leaveRequests,
      docId: requestId,
    );
  }

  @override
  Stream<List<HolidayModel>> getHolidaysStream() {
    return _firestoreService.collectionStream<HolidayModel>(
      path: FirestoreConstants.holidays,
      builder: (data, documentId) => HolidayModel.fromMap(data, documentId),
      sort: (a, b) => a.startDate.compareTo(b.startDate),
    );
  }

  @override
  Future<void> addHoliday(HolidayModel holiday) {
    return _firestoreService.addDocument(
      path: FirestoreConstants.holidays,
      data: holiday.toMap(),
      docId: holiday.id.isNotEmpty ? holiday.id : null,
    );
  }

  @override
  Future<void> deleteHoliday(String holidayId) {
    return _firestoreService.deleteDocument(
      path: FirestoreConstants.holidays,
      docId: holidayId,
    );
  }
}
