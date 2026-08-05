import 'package:sample_app/features/leave/domain/entities/holiday.dart';
import 'package:sample_app/features/leave/domain/entities/leave_request.dart';

abstract class LeaveRepository {
  Stream<List<LeaveRequestModel>> getLeaveRequestsStream();
  Future<void> submitLeaveRequest(LeaveRequestModel request);
  Future<void> approveLeave(String requestId);
  Future<void> rejectLeave(String requestId);
  Future<void> deleteLeaveRequest(String requestId);

  Stream<List<Holiday>> getHolidaysStream();
  Future<void> addHoliday(Holiday holiday);
  Future<void> deleteHoliday(String holidayId);
}
