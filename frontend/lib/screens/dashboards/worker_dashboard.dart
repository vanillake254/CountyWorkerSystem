import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../models/payment.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/vanilla_branding.dart';
import '../../widgets/exit_confirmation_wrapper.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});
  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];
  List<Payment> _payments = [];
  List<Job> _jobs = [];
  List<Application> _applications = [];
  bool _isLoadingTasks = true;
  bool _isLoadingPayments = true;
  bool _isLoadingJobs = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadPayments();
    _loadJobs();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoadingTasks = true);
    try {
      final response = await _apiService.getTasks();
      if (response['status'] == 'success') {
        setState(() {
          _tasks = (response['tasks'] as List)
              .map((task) => Task.fromJson(task))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingTasks = false);
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoadingPayments = true);
    try {
      final response = await _apiService.getPayments();
      if (response['status'] == 'success') {
        setState(() {
          _payments = (response['payments'] as List)
              .map((payment) => Payment.fromJson(payment))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingPayments = false);
    }
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoadingJobs = true);
    try {
      final jobsResponse = await _apiService.getJobs();
      final appsResponse = await _apiService.getApplications();
      
      if (jobsResponse['status'] == 'success') {
        setState(() {
          _jobs = (jobsResponse['jobs'] as List)
              .map((job) => Job.fromJson(job))
              .toList();
        });
      }
      
      if (appsResponse['status'] == 'success') {
        setState(() {
          _applications = (appsResponse['applications'] as List)
              .map((app) => Application.fromJson(app))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading jobs: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingJobs = false);
    }
  }

  Future<void> _applyForJob(Job job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Job'),
        content: Text('Do you want to apply for ${job.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.applyForJob(job.id);
        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Application submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadJobs();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to apply'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateTaskProgress(Task task) async {
    final statuses = ['pending', 'in_progress', 'completed'];
    final currentIndex = statuses.indexOf(task.progressStatus);
    
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Task Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return RadioListTile<String>(
              title: Text(status.replaceAll('_', ' ').toUpperCase()),
              value: status,
              groupValue: task.progressStatus,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && selected != task.progressStatus) {
      try {
        final response = await _apiService.updateTask(task.id, selected);
        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadTasks();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to update task'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Widget _buildTasksList() {
    if (_isLoadingTasks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return const Center(
        child: Text('No tasks assigned yet'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          
          Color statusColor;
          IconData statusIcon;
          
          if (task.isPending) {
            statusColor = Colors.orange;
            statusIcon = Icons.pending_actions;
          } else if (task.isInProgress) {
            statusColor = Colors.blue;
            statusIcon = Icons.play_circle;
          } else {
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Supervisor: ${task.supervisorName ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.progressStatus.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(task.description),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Start: ${_formatDate(task.startDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.event, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'End: ${_formatDate(task.endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _updateTaskProgress(task),
                      icon: const Icon(Icons.edit),
                      label: const Text('Update Progress'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsList() {
    if (_isLoadingPayments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_payments.isEmpty) {
      return const Center(
        child: Text('No payment records yet'),
      );
    }

    final totalEarnings = _payments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final paidAmount = _payments
        .where((p) => p.isPaid)
        .fold<double>(0, (sum, payment) => sum + payment.amount);
    final pendingAmount = totalEarnings - paidAmount;

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Paid',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'KES ${paidAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Pending',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'KES ${pendingAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Payment list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      payment.isPaid ? Icons.check_circle : Icons.pending,
                      color: payment.isPaid ? Colors.green : Colors.orange,
                      size: 40,
                    ),
                    title: Text(
                      'KES ${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (payment.taskTitle != null)
                          Text('Task: ${payment.taskTitle}'),
                        Text('Date: ${_formatDate(payment.date)}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: payment.isPaid ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return ExitConfirmationWrapper(
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authProvider.logout();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedIndex == 0 
                ? _buildTasksList() 
                : _selectedIndex == 1 
                    ? _buildPaymentsList() 
                    : _buildJobsList(),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[100],
            child: const VanillaBranding(compact: true),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Available Jobs',
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildJobsList() {
    if (_isLoadingJobs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_jobs.isEmpty) {
      return const Center(
        child: Text('No open jobs available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          final hasApplied = _applications.any((app) => app.jobId == job.id && app.jobId != null);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: job.isOpen ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          job.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        job.departmentName ?? 'Unknown Department',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(job.description),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasApplied || !job.isOpen
                          ? null
                          : () => _applyForJob(job),
                      child: Text(
                        hasApplied
                            ? 'Already Applied'
                            : job.isOpen
                                ? 'Apply Now'
                                : 'Closed',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
