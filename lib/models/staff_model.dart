// Models shared across the whole app.

// ---------------------------------------------------------------------------
// Staff
// ---------------------------------------------------------------------------
class StaffModel {
  final String id, name, email, role, dept, status;

  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.dept,
    required this.status,
  });
}

// ---------------------------------------------------------------------------
// Leave
// ---------------------------------------------------------------------------
enum LeaveStatus { pending, approved, rejected }

class LeaveRequest {
  final String name;
  final String role;
  final String employeeId;
  final String leaveType;
  final String dateRange;
  final String initials;
  final LeaveStatus status;

  const LeaveRequest({
    required this.name,
    required this.role,
    required this.employeeId,
    required this.leaveType,
    required this.dateRange,
    required this.initials,
    this.status = LeaveStatus.pending,
  });
}

// ---------------------------------------------------------------------------
// Static staff list
// ---------------------------------------------------------------------------
const List<StaffModel> allStaffList = [
  StaffModel(
    id: 'F001',
    name: 'Dr. Alice Johnson',
    email: 'alice.j@engg.edu',
    role: 'Professor',
    dept: 'CSE',
    status: 'Present',
  ),
  StaffModel(
    id: 'F002',
    name: 'Prof. Bob Martin',
    email: 'bob.m@engg.edu',
    role: 'Asst. Prof',
    dept: 'ECE',
    status: 'Absent',
  ),
  StaffModel(
    id: 'F003',
    name: 'Dr. Carol White',
    email: 'carol.w@engg.edu',
    role: 'HOD',
    dept: 'MECH',
    status: 'Present',
  ),
  StaffModel(
    id: 'F004',
    name: 'David Lee',
    email: 'david.l@engg.edu',
    role: 'Lab Instructor',
    dept: 'IT',
    status: 'Present',
  ),
  StaffModel(
    id: 'F005',
    name: 'Dr. Eva Chen',
    email: 'eva.c@engg.edu',
    role: 'Professor',
    dept: 'AI&DS',
    status: 'Absent',
  ),
  StaffModel(
    id: 'F006',
    name: 'Dr. Mark Smith',
    email: 'mark.s@engg.edu',
    role: 'Professor',
    dept: 'CIVIL',
    status: 'Present',
  ),
];
