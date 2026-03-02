import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/app_shell.dart';

void main() => runApp(const StaffAdminApp());

class StaffAdminApp extends StatelessWidget {
  const StaffAdminApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'College Staff Portal',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: const AppShell(),
  );
}

// -------------------------------------------------------------
// REUSABLE UI COMPONENTS (States & Interactions)
// -------------------------------------------------------------

// -------------------------------------------------------------
// HEADER & NAVIGATION
// -------------------------------------------------------------

// -------------------------------------------------------------
// DASHBOARD SCREEN
// -------------------------------------------------------------

// -------------------------------------------------------------
// USERS SCREEN (STAFF DIRECTORY) WITH SEARCH STATE
// -------------------------------------------------------------

//-------------------------------------------------------------
// ATTENDANCE REQUEST
//--------------------------------------------------------------
class LeaveRequests extends StatelessWidget {
  const LeaveRequests({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

// -------------------------------------------------------------
// REPORTS SCREEN WITH LOADING STATE
// -------------------------------------------------------------

// -------------------------------------------------------------
// SETTINGS SCREEN (Redesigned Hierarchy)
// -------------------------------------------------------------
