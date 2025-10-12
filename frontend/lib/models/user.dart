class User {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final int? departmentId;
  final String? departmentName;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.departmentId,
    this.departmentName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'],
      role: json['role'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
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
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isSupervisor => role == 'supervisor';
  bool get isWorker => role == 'worker';
  bool get isApplicant => role == 'applicant';
}
