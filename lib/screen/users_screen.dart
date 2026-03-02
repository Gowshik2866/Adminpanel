import 'package:flutter/material.dart';
import 'package:sample_app/models/staff_model.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/animated_hover_card.dart';
import 'package:sample_app/widgets/empty_state_view.dart';
import 'package:sample_app/widgets/section_title.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String searchQuery = '';

  List<StaffModel> get filteredStaff {
    if (searchQuery.isEmpty) return allStaffList;
    final query = searchQuery.toLowerCase();
    return allStaffList
        .where(
          (u) =>
              u.name.toLowerCase().contains(query) ||
              u.dept.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final staffData = filteredStaff;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Staff Directory',
              subtitle: 'Manage engineering college staff profiles and access.',
            ),
            const SizedBox(height: 32),

            // Search Bar with improved Visual Purpose & States
            TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by staff name or department...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primary,
                ),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Handle Empty State
            if (staffData.isEmpty)
              const EmptyStateView(
                message: "No staff found matching your search.",
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1100
                      ? 3
                      : (constraints.maxWidth > 700 ? 2 : 1);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 96,
                    ),
                    itemCount: staffData.length,
                    itemBuilder: (context, index) {
                      final staff = staffData[index];
                      final bool isPresent = staff.status == 'Present';

                      return AnimatedHoverCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primaryLight,
                              child: Text(
                                staff.name[0],
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    staff.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${staff.role} • ${staff.dept}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? AppTheme.successLight
                                    : AppTheme.dangerLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                staff.status,
                                style: TextStyle(
                                  color: isPresent
                                      ? AppTheme.success
                                      : AppTheme.danger,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
