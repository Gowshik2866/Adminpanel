// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/core/firestore/firestore_service.dart';
import 'package:sample_app/data/mock_data.dart';
import 'package:sample_app/features/attendance/data/models/attendance_model.dart';
import 'package:sample_app/features/leave/data/models/leave_request_data_model.dart';
import 'package:sample_app/features/settings/data/models/system_settings_model.dart';
import 'package:sample_app/features/staff/data/models/staff_model.dart';
import 'package:sample_app/firebase_options.dart';
import 'package:sample_app/core/firestore/firestore_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestoreService = FirestoreService();

  print('Starting Firestore Seed...');

  // Seed Settings
  print('Seeding Settings...');
  await firestoreService.addDocument(
    path: FirestoreConstants.settings,
    data: SystemSettingsModel.fromEntity(MockData.defaultSettings).toMap(),
    docId: 'global_settings',
  );

  // Seed Staff
  print('Seeding Staff...');
  for (final staff in MockData.initialStaff) {
    await firestoreService.addDocument(
      path: FirestoreConstants.staff,
      data: StaffModel.fromEntity(staff).toMap(),
      docId: staff.id,
    );
  }

  // Seed Attendance
  print('Seeding Attendance...');
  for (final attendance in MockData.initialAttendance) {
    await firestoreService.addDocument(
      path: FirestoreConstants.attendance,
      data: AttendanceModel.fromEntity(attendance).toMap(),
      docId: attendance.id,
    );
  }

  // Seed Leave Requests
  print('Seeding Leave Requests...');
  for (final leave in MockData.initialLeaveRequests) {
    await firestoreService.addDocument(
      path: FirestoreConstants.leaveRequests,
      data: LeaveRequestDataModel.fromEntity(leave).toMap(),
      docId: leave.id,
    );
  }

  print('Firestore Seed Complete!');
  exit(0);
}
