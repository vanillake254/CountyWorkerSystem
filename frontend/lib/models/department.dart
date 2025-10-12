class Department {
  final int id;
  final String name;
  final int? supervisorId;
  final String? supervisorName;
  final String createdAt;

  Department({
    required this.id,
    required this.name,
    this.supervisorId,
    this.supervisorName,
    required this.createdAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      supervisorId: json['supervisor_id'],
      supervisorName: json['supervisor_name'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'supervisor_id': supervisorId,
      'supervisor_name': supervisorName,
      'created_at': createdAt,
    };
  }
}
