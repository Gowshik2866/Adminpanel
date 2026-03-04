import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/leave_request.dart';
import 'package:sample_app/data/mock_data.dart';
import 'package:sample_app/providers/attendance_provider.dart';
import 'package:uuid/uuid.dart';

class LeaveNotifier extends StateNotifier<List<LeaveRequestModel>> {
  final Ref ref;
  final _uuid = const Uuid();

  LeaveNotifier(this.ref) : super(MockData.initialLeaveRequests);

  void applyLeave(LeaveRequestModel req) {
    state = [...state, req.copyWith(id: _uuid.v4())];
  }

  void approveLeave(String id) {
    LeaveRequestModel? approvedReq;
    state = state.map((req) {
      if (req.id == id) {
        approvedReq = req.copyWith(status: LeaveStatus.approved);
        return approvedReq!;
      }
      return req;
    }).toList();

    // Side effect: update attendance
    if (approvedReq != null) {
      ref
          .read(attendanceProvider.notifier)
          .markLeaveForRange(
            approvedReq!.staff.id,
            approvedReq!.startDate,
            approvedReq!.endDate,
          );
    }
  }

  void rejectLeave(String id) {
    state = state.map((req) {
      if (req.id == id) {
        return req.copyWith(status: LeaveStatus.rejected);
      }
      return req;
    }).toList();
  }
}

final leaveProvider =
    StateNotifierProvider<LeaveNotifier, List<LeaveRequestModel>>((ref) {
      return LeaveNotifier(ref);
    });

final pendingLeavesProvider = Provider<List<LeaveRequestModel>>((ref) {
  final leaves = ref.watch(leaveProvider);
  return leaves.where((l) => l.status == LeaveStatus.pending).toList();
});
