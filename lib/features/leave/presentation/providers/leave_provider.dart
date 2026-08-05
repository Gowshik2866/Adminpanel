import 'dart:developer' as import_developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/core/providers.dart';
import 'package:sample_app/features/leave/data/repositories/leave_repository_impl.dart';
import 'package:sample_app/features/leave/data/sources/leave_remote_data_source.dart';
import 'package:sample_app/features/leave/domain/entities/leave_request.dart';
import 'package:sample_app/features/leave/domain/repositories/leave_repository.dart';
import 'package:sample_app/features/attendance/presentation/providers/attendance_provider.dart';

final leaveRemoteDataSourceProvider = Provider<LeaveRemoteDataSource>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return LeaveRemoteDataSourceImpl(firestoreService);
});

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  final remoteDataSource = ref.watch(leaveRemoteDataSourceProvider);
  return LeaveRepositoryImpl(remoteDataSource: remoteDataSource);
});

final leaveStreamProvider = StreamProvider<List<LeaveRequestModel>>((ref) {
  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getLeaveRequestsStream();
});

class LeaveController {
  final Ref _ref;
  final LeaveRepository _repository;
  
  LeaveController(this._ref, this._repository);

  Future<void> applyLeave(LeaveRequestModel req) {
    return _repository.submitLeaveRequest(req);
  }

  Future<void> approveLeave(String id) async {
    await _repository.approveLeave(id);
    
    // Find the request from the current state to update attendance
    final currentLeaves = _ref.read(leaveProvider);
    try {
      final req = currentLeaves.firstWhere((element) => element.id == id);
      _ref.read(attendanceControllerProvider).markLeaveForRange(
        req.staff.id,
        req.startDate,
        req.endDate,
      );
    } catch (e, stackTrace) {
      import_developer.log('Failed to integrate approved leave with attendance.', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> rejectLeave(String id) {
    return _repository.rejectLeave(id);
  }
}

final leaveControllerProvider = Provider<LeaveController>((ref) {
  final repository = ref.watch(leaveRepositoryProvider);
  return LeaveController(ref, repository);
});

// Backward compatible provider for UI
final leaveProvider = Provider<List<LeaveRequestModel>>((ref) {
  final asyncLeaves = ref.watch(leaveStreamProvider);
  return asyncLeaves.value ?? [];
});

final pendingLeavesProvider = Provider<List<LeaveRequestModel>>((ref) {
  final leaves = ref.watch(leaveProvider);
  return leaves.where((l) => l.status == LeaveStatus.pending).toList();
});
