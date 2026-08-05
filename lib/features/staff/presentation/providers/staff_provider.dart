import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/core/providers.dart';
import 'package:sample_app/features/staff/data/repositories/staff_repository_impl.dart';
import 'package:sample_app/features/staff/data/sources/staff_remote_data_source.dart';
import 'package:sample_app/features/staff/domain/entities/staff.dart';
import 'package:sample_app/features/staff/domain/repositories/staff_repository.dart';

final staffRemoteDataSourceProvider = Provider<StaffRemoteDataSource>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return StaffRemoteDataSourceImpl(firestoreService);
});

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final remoteDataSource = ref.watch(staffRemoteDataSourceProvider);
  return StaffRepositoryImpl(remoteDataSource: remoteDataSource);
});

final staffStreamProvider = StreamProvider<List<Staff>>((ref) {
  final repository = ref.watch(staffRepositoryProvider);
  return repository.getStaffListStream();
});

// For mutating data, we create a simple Notifier/Controller.
class StaffController {
  final StaffRepository _repository;
  StaffController(this._repository);

  Future<void> addStaff(Staff staff) {
    return _repository.addStaff(staff);
  }

  Future<void> updateStaff(Staff staff) {
    return _repository.updateStaff(staff);
  }

  Future<void> deleteStaff(String staffId) async {
    // Ideally we'd fetch the existing staff and update it.
    // For simplicity, we just delete it from Firestore for now.
    // Or we update the specific status field if we had a dedicated updateStatus method.
    // Here we'll delete to clean up data.
    return _repository.deleteStaff(staffId);
  }
}

final staffControllerProvider = Provider<StaffController>((ref) {
  final repository = ref.watch(staffRepositoryProvider);
  return StaffController(repository);
});

final staffProvider = Provider<List<Staff>>((ref) {
  final staffAsync = ref.watch(staffStreamProvider);
  return staffAsync.value ?? [];
});

// A derived provider for active staff only, keeping backward compatibility
final activeStaffProvider = Provider<List<Staff>>((ref) {
  final staffList = ref.watch(staffProvider);
  return staffList.where((s) => s.status == StaffStatus.active).toList();
});
