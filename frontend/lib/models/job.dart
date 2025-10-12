class Job {
  final int id;
  final String title;
  final String description;
  final int departmentId;
  final String? departmentName;
  final String status;
  final String createdAt;
  final int? applicationsCount;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.departmentId,
    this.departmentName,
    required this.status,
    required this.createdAt,
    this.applicationsCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      status: json['status'],
      createdAt: json['created_at'],
      applicationsCount: json['applications_count'],
    );
  }

  bool get isOpen => status == 'open';
}
