import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/holiday.dart';
import 'package:sample_app/providers/holiday_provider.dart';
import 'package:sample_app/widgets/empty_state_view.dart';

class HolidayDetailsScreen extends ConsumerStatefulWidget {
  const HolidayDetailsScreen({super.key});

  @override
  ConsumerState<HolidayDetailsScreen> createState() =>
      _HolidayDetailsScreenState();
}

class _HolidayDetailsScreenState extends ConsumerState<HolidayDetailsScreen> {
  String _selectedDept = 'All Departments';

  List<Holiday> _filterAndSort(List<Holiday> holidays) {
    var filtered = holidays.where((h) {
      bool deptMatch =
          _selectedDept == 'All Departments' ||
          h.department == _selectedDept ||
          h.department == 'All';
      return deptMatch;
    }).toList();

    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
    return filtered;
  }

  String _formatDateRange(DateTime start, DateTime end) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    String startStr = '${start.day} ${months[start.month - 1]}';
    String endStr = '${end.day} ${months[end.month - 1]}';
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return startStr;
    }
    return '$startStr – $endStr';
  }

  void _showHolidayForm({Holiday? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    DateTime selectedStartDate = existing?.startDate ?? DateTime.now();
    DateTime selectedEndDate = existing?.endDate ?? DateTime.now();
    String selectedDept = existing?.department ?? 'All';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Holiday' : 'Edit Holiday'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Dates:'),
                        SizedBox(width: 16),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: ctx,
                              initialDateRange: DateTimeRange(
                                start: selectedStartDate,
                                end: selectedEndDate,
                              ),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedStartDate = picked.start;
                                selectedEndDate = picked.end;
                              });
                            }
                          },
                          child: Text(
                            '${'${selectedStartDate.toLocal()}'.split(' ')[0]} to ${'${selectedEndDate.toLocal()}'.split(' ')[0]}',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDept,
                      items:
                          ['All', 'CSE', 'ECE', 'MECH', 'IT', 'AI&DS', 'CIVIL']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (v) => setDialogState(() => selectedDept = v!),
                      decoration: const InputDecoration(
                        labelText: 'Department',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final notifier = ref.read(holidayProvider.notifier);
                    if (existing == null) {
                      notifier.addHoliday(
                        titleController.text,
                        descController.text,
                        selectedStartDate,
                        selectedEndDate,
                        selectedDept,
                      );
                    } else {
                      notifier.updateHoliday(
                        existing.copyWith(
                          title: titleController.text,
                          description: descController.text,
                          startDate: selectedStartDate,
                          endDate: selectedEndDate,
                          department: selectedDept,
                        ),
                      );
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final holidays = ref.watch(holidayProvider);
    final displayedHolidays = _filterAndSort(holidays);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedDept,
                    items:
                        [
                              'All Departments',
                              'CSE',
                              'ECE',
                              'MECH',
                              'IT',
                              'AI&DS',
                              'CIVIL',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedDept = v!),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showHolidayForm(),
                icon: Icon(Icons.add),
                label: Text('Add Holiday'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: displayedHolidays.isEmpty
              ? const EmptyStateView(
                  message: 'No holidays found matching criteria.',
                  icon: Icons.event_busy_rounded,
                )
              : ListView.separated(
                  padding: EdgeInsets.all(24),
                  itemCount: displayedHolidays.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final h = displayedHolidays[index];
                    return Card(
                      color: Theme.of(context).cardColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.event_available_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          h.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(h.description),
                            SizedBox(height: 4),
                            Text(
                              '${_formatDateRange(h.startDate, h.endDate)} • Dept: ${h.department}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () => _showHolidayForm(existing: h),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () {
                                ref
                                    .read(holidayProvider.notifier)
                                    .deleteHoliday(h.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
