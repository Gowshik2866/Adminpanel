class Holiday {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String department;

  const Holiday({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.department,
  });

  Holiday copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? department,
  }) {
    return Holiday(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      department: department ?? this.department,
    );
  }
}
