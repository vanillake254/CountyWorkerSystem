class Payment {
  final int id;
  final int workerId;
  final String? workerName;
  final int? taskId;
  final String? taskTitle;
  final double amount;
  final String status;
  final String date;
  final String? paidAt;

  Payment({
    required this.id,
    required this.workerId,
    this.workerName,
    this.taskId,
    this.taskTitle,
    required this.amount,
    required this.status,
    required this.date,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      workerId: json['worker_id'],
      workerName: json['worker_name'],
      taskId: json['task_id'],
      taskTitle: json['task_title'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      date: json['date'],
      paidAt: json['paid_at'],
    );
  }

  bool get isPaid => status == 'paid';
  bool get isUnpaid => status == 'unpaid';
}
