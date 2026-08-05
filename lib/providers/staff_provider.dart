import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/staff.dart';
import 'package:sample_app/data/mock_data.dart';
import 'package:uuid/uuid.dart';

class StaffNotifier extends StateNotifier<List<Staff>> {
  final _uuid = const Uuid();

  StaffNotifier() : super(MockData.initialStaff);

  void addStaff(Staff staff) {
    final newStaff = staff.copyWith(id: _uuid.v4());
    state = [...state, newStaff];
  }

  void updateStaff(Staff updatedStaff) {
    state = [
      for (final staff in state)
        if (staff.id == updatedStaff.id) updatedStaff else staff,
    ];
  }

  void softDeleteStaff(String staffId) {
    state = [
      for (final staff in state)
        if (staff.id == staffId)
          staff.copyWith(status: StaffStatus.inactive)
        else
          staff,
    ];
  }

  List<Staff> get activeStaff {
    return state.where((staff) => staff.status == StaffStatus.active).toList();
  }
}

final staffProvider = StateNotifierProvider<StaffNotifier, List<Staff>>((ref) {
  return StaffNotifier();
});

// A derived provider for active staff only (if needed by views)
final activeStaffProvider = Provider<List<Staff>>((ref) {
  final staffList = ref.watch(staffProvider);
  return staffList.where((s) => s.status == StaffStatus.active).toList();
});
