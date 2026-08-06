import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/leave_request.dart';
import 'package:sample_app/repositories/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository();
});

final leaveProvider = StreamProvider<List<LeaveRequestModel>>((ref) {
  return ref.read(leaveRepositoryProvider).watchLeaveRequests();
});
