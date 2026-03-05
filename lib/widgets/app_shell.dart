import 'package:flutter/material.dart';
import 'package:sample_app/screen/dashboard_screen.dart';
import 'package:sample_app/screen/leave_requests_screen.dart';
import 'package:sample_app/screen/report_screen.dart';
import 'package:sample_app/screen/settings_screen.dart';
import 'package:sample_app/screen/users_screen.dart';
import 'package:sample_app/widgets/app_sidebar.dart';
import 'package:sample_app/widgets/top_header.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int navIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    UsersScreen(),
    ReportsScreen(),
    LeaveRequestsScreen(), // index 3 — Leave Management
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const TopHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSidebar(
                  selectedIndex: navIndex,
                  onItemSelected: (i) => setState(() => navIndex = i),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(navIndex),
                      child: _screens[navIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
