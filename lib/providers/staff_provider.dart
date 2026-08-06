import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/staff.dart';
import 'package:sample_app/repositories/staff_repository.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository();
});

final staffProvider = StreamProvider<List<Staff>>((ref) {
  return ref.read(staffRepositoryProvider).watchStaff();
});
