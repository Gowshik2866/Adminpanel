import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/core/enums.dart';
import 'package:sample_app/models/staff.dart';
import 'package:sample_app/models/system_settings.dart';
import 'package:sample_app/models/user.dart';

void main() {
  group('Domain Models Test Suite', () {
    test('Staff model serialization and copyWith', () {
      final now = DateTime.now();
      final staff = Staff(
        id: 's1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        dept: 'CSE',
        role: 'Professor',
        joiningDate: now,
        employmentType: EmploymentType.fullTime,
        status: StaffStatus.active,
      );

      final json = staff.toJson();
      final deserialized = Staff.fromJson(json);

      expect(deserialized.id, equals('s1'));
      expect(deserialized.name, equals('John Doe'));
      expect(deserialized.status, equals(StaffStatus.active));

      final updated = staff.copyWith(name: 'Jane Doe');
      expect(updated.name, equals('Jane Doe'));
      expect(updated.id, equals('s1'));
    });

    test('SystemSettings default instantiation', () {
      const settings = SystemSettings(
        workOnSaturdays: false,
        officeStartTime: '09:00 AM',
        officeEndTime: '05:00 PM',
        maxSickLeaves: 12,
        maxCasualLeaves: 12,
        maxAnnualLeaves: 15,
      );

      expect(settings.workOnSaturdays, isFalse);
      expect(settings.maxSickLeaves, equals(12));

      final json = settings.toJson();
      final fromJson = SystemSettings.fromJson(json);
      expect(fromJson.officeStartTime, equals('09:00 AM'));
    });

    test('User model role parsing', () {
      final user = User(
        id: 'u1',
        name: 'Admin',
        email: 'admin@example.com',
        role: Role.admin,
        lastLogin: DateTime.now(),
      );

      final json = user.toJson();
      final restored = User.fromJson(json);

      expect(restored.role, equals(Role.admin));
      expect(restored.name, equals('Admin'));
    });
  });
}
