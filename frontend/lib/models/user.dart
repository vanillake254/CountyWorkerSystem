class User {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final int? departmentId;
  final String? departmentName;
  final double? salary;
  final double? salaryBalance;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.departmentId,
    this.departmentName,
    this.salary,
    this.salaryBalance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'],
      role: json['role'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      salary: json['salary']?.toDouble(),
      salaryBalance: json['salary_balance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'department_id': departmentId,
      'department_name': departmentName,
      'salary': salary,
      'salary_balance': salaryBalance,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isSupervisor => role == 'supervisor';
  bool get isWorker => role == 'worker';
  bool get isApplicant => role == 'applicant';
}
