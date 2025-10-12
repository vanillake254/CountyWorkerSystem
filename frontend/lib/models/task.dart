class Task {
  final int id;
  final String title;
  final String description;
  final int assignedTo;
  final String? workerName;
  final int supervisorId;
  final String? supervisorName;
  final String progressStatus;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    this.workerName,
    required this.supervisorId,
    this.supervisorName,
    required this.progressStatus,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      assignedTo: json['assigned_to'],
      workerName: json['worker_name'],
      supervisorId: json['supervisor_id'],
      supervisorName: json['supervisor_name'],
      progressStatus: json['progress_status'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
    );
  }

  bool get isPending => progressStatus == 'pending';
  bool get isInProgress => progressStatus == 'in_progress';
  bool get isCompleted => progressStatus == 'completed';
}
