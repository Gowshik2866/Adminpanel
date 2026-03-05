import 'package:flutter/material.dart';
import 'package:sample_app/widgets/navigation_item_data.dart';
import 'package:sample_app/widgets/navigation_title.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<NavigationItemData> items = [
    NavigationItemData(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    NavigationItemData(
      icon: Icons.people_alt_outlined,
      label: 'Staff Directory',
    ),
    NavigationItemData(icon: Icons.bar_chart_rounded, label: 'Reports'),
    NavigationItemData(icon: Icons.calendar_month, label: 'Leave Management'),
    NavigationItemData(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                items.length,
                (i) => NavigationTile(
                  item: items[i],
                  selected: selectedIndex == i,
                  onTap: () => onItemSelected(i),
                ),
              ),
            ),
          ),
          const Spacer(),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: EdgeInsets.all(16),
            child: NavigationTile(
              item: const NavigationItemData(
                icon: Icons.logout_rounded,
                label: 'Logout',
              ),
              selected: false,
              onTap: () {}, // Single consistent logout location
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
