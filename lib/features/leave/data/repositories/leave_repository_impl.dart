import 'package:sample_app/features/leave/data/models/holiday_model.dart';
import 'package:sample_app/features/leave/data/models/leave_request_data_model.dart';
import 'package:sample_app/features/leave/data/sources/leave_remote_data_source.dart';
import 'package:sample_app/features/leave/domain/entities/holiday.dart';
import 'package:sample_app/features/leave/domain/entities/leave_request.dart';
import 'package:sample_app/features/leave/domain/repositories/leave_repository.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;

  LeaveRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<LeaveRequestModel>> getLeaveRequestsStream() {
    return remoteDataSource.getLeaveRequestsStream();
  }

  @override
  Future<void> submitLeaveRequest(LeaveRequestModel request) {
    return remoteDataSource.submitLeaveRequest(LeaveRequestDataModel.fromEntity(request));
  }

  @override
  Future<void> approveLeave(String requestId) {
    return remoteDataSource.approveLeave(requestId);
  }

  @override
  Future<void> rejectLeave(String requestId) {
    return remoteDataSource.rejectLeave(requestId);
  }

  @override
  Future<void> deleteLeaveRequest(String requestId) {
    return remoteDataSource.deleteLeaveRequest(requestId);
  }

  @override
  Stream<List<Holiday>> getHolidaysStream() {
    return remoteDataSource.getHolidaysStream();
  }

  @override
  Future<void> addHoliday(Holiday holiday) {
    return remoteDataSource.addHoliday(HolidayModel.fromEntity(holiday));
  }

  @override
  Future<void> deleteHoliday(String holidayId) {
    return remoteDataSource.deleteHoliday(holidayId);
  }
}
