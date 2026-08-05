import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/staff.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/animated_hover_card.dart';
import 'package:sample_app/widgets/empty_state_view.dart';
import 'package:sample_app/widgets/section_title.dart';
import 'package:sample_app/providers/staff_provider.dart';
import 'package:sample_app/core/enums.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});
  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String searchQuery = '';
  String? selectedDept;

  List<Staff> _filteredStaff(List<Staff> staffList) {
    var list = staffList;
    if (selectedDept != null && selectedDept != 'All') {
      list = list.where((s) => s.dept == selectedDept).toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      list = list
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.dept.toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final activeStaff = ref.watch(activeStaffProvider);
    final staffData = _filteredStaff(activeStaff);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: SectionTitle(
                    title: 'Staff Directory',
                    subtitle:
                        'Manage engineering college staff profiles and access.',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddStaffDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Add Staff',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
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
                      // For UI purposes, pretending Active means Present, Inactive means Absent just visually like original for now,
                      // or better: map status to UI colors. Originally used 'Present'. Now we use StaffStatus.
                      final bool isActive = staff.status == StaffStatus.active;

                      return AnimatedHoverCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primaryLight,
                              child: Text(
                                staff.name[0].toUpperCase(),
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
                                color: isActive
                                    ? AppTheme.successLight
                                    : AppTheme.dangerLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: isActive
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

  void _showAddStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _AddStaffDialog(),
    );
  }
}

class _AddStaffDialog extends ConsumerStatefulWidget {
  const _AddStaffDialog();

  @override
  ConsumerState<_AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends ConsumerState<_AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String phone = '';
  String dept = 'Computer Science';
  String role = 'Professor';
  EmploymentType empType = EmploymentType.fullTime;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Staff',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter details to register a new staff member.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              TextFormField(
                decoration: _inputDecoration('Full Name', Icons.person_outline),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: _inputDecoration(
                  'Email Address',
                  Icons.email_outlined,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
                onSaved: (v) => email = v!,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDecoration(
                        'Phone',
                        Icons.phone_outlined,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => phone = v!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: dept,
                      decoration: _inputDecoration(
                        'Department',
                        Icons.business_outlined,
                      ),
                      items:
                          [
                                'Computer Science',
                                'Mechanical',
                                'Electrical',
                                'Civil',
                              ]
                              .map(
                                (d) =>
                                    DropdownMenuItem(value: d, child: Text(d)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => dept = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: _inputDecoration(
                        'Role',
                        Icons.badge_outlined,
                      ),
                      items:
                          [
                                'Professor',
                                'Asst Professor',
                                'HOD',
                                'Lab Instructor',
                              ]
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => role = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<EmploymentType>(
                      initialValue: empType,
                      decoration: _inputDecoration('Type', Icons.work_outline),
                      items: EmploymentType.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => empType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Add Staff'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check for duplicate email
      final allStaff = ref.read(staffProvider);
      if (allStaff.any((s) => s.email.toLowerCase() == email.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Email already exists.')),
        );
        return;
      }

      final newStaff = Staff(
        id: '', // Will be generated in staffProvider
        name: name,
        email: email,
        phone: phone,
        dept: dept,
        role: role,
        employmentType: empType,
        joiningDate: DateTime.now(),
        status: StaffStatus.active,
      );

      ref.read(staffProvider.notifier).addStaff(newStaff);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name added successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );

      Navigator.pop(context);
    }
  }
}
