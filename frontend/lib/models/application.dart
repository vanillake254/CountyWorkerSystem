class Application {
  final int id;
  final int applicantId;
  final String? applicantName;
  final String? applicantEmail;
  final int jobId;
  final String? jobTitle;
  final String? department;
  final String status;
  final String appliedAt;
  final String? reviewedAt;

  Application({
    required this.id,
    required this.applicantId,
    this.applicantName,
    this.applicantEmail,
    required this.jobId,
    this.jobTitle,
    this.department,
    required this.status,
    required this.appliedAt,
    this.reviewedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      applicantId: json['applicant_id'],
      applicantName: json['applicant_name'],
      applicantEmail: json['applicant_email'],
      jobId: json['job_id'],
      jobTitle: json['job_title'],
      department: json['department'],
      status: json['status'],
      appliedAt: json['applied_at'],
      reviewedAt: json['reviewed_at'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
