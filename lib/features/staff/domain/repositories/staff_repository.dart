import 'package:sample_app/features/staff/domain/entities/staff.dart';

abstract class StaffRepository {
  Stream<List<Staff>> getStaffListStream();
  Future<List<Staff>> getStaffList();
  Future<void> addStaff(Staff staff);
  Future<void> updateStaff(Staff staff);
  Future<void> deleteStaff(String staffId);
}
