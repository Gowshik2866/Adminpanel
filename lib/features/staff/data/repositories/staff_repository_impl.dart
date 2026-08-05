import 'package:sample_app/features/staff/data/models/staff_model.dart';
import 'package:sample_app/features/staff/data/sources/staff_remote_data_source.dart';
import 'package:sample_app/features/staff/domain/entities/staff.dart';
import 'package:sample_app/features/staff/domain/repositories/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Staff>> getStaffListStream() {
    return remoteDataSource.getStaffListStream();
  }

  @override
  Future<List<Staff>> getStaffList() {
    return remoteDataSource.getStaffList();
  }

  @override
  Future<void> addStaff(Staff staff) {
    return remoteDataSource.addStaff(StaffModel.fromEntity(staff));
  }

  @override
  Future<void> updateStaff(Staff staff) {
    return remoteDataSource.updateStaff(StaffModel.fromEntity(staff));
  }

  @override
  Future<void> deleteStaff(String staffId) {
    return remoteDataSource.deleteStaff(staffId);
  }
}
