import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../models/user.dart' as models;
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/vanilla_branding.dart';
import '../../widgets/exit_confirmation_wrapper.dart';
import 'package:intl/intl.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];
  List<models.User> _workers = [];
  bool _isLoadingTasks = true;
  bool _isLoadingWorkers = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadWorkers();
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

  Future<void> _loadWorkers() async {
    setState(() => _isLoadingWorkers = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final departmentId = authProvider.currentUser?.departmentId;
      
      if (departmentId != null) {
        final response = await _apiService.getDepartmentWorkers(departmentId);
        if (response['status'] == 'success') {
          setState(() {
            _workers = (response['workers'] as List)
                .map((worker) => models.User.fromJson(worker))
                .toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading workers: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingWorkers = false);
    }
  }

  Future<void> _showCreateTaskDialog() async {
    if (_workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No workers available in your department'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    models.User? selectedWorker;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assign New Task'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter task title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<models.User>(
                    value: selectedWorker,
                    decoration: const InputDecoration(
                      labelText: 'Assign to Worker',
                      border: OutlineInputBorder(),
                    ),
                    items: _workers.map((worker) {
                      return DropdownMenuItem(
                        value: worker,
                        child: Text(worker.fullName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedWorker = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a worker';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          startDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(endDate)),
                    trailing: const Icon(Icons.event),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          endDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && selectedWorker != null) {
                  try {
                    final response = await _apiService.createTask(
                      title: titleController.text,
                      description: descriptionController.text,
                      assignedTo: selectedWorker!.id,
                      startDate: startDate.toIso8601String(),
                      endDate: endDate.toIso8601String(),
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                      
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task assigned successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadTasks();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message'] ?? 'Failed to create task'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Assign Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    if (_isLoadingTasks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No tasks assigned yet'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateTaskDialog,
              icon: const Icon(Icons.add),
              label: const Text('Assign First Task'),
            ),
          ],
        ),
      );
    }

    final incompleteTasks = _tasks.where((t) => t.isIncomplete).length;
    final completedTasks = _tasks.where((t) => t.isCompleted).length;
    final approvedTasks = _tasks.where((t) => t.isApproved).length;
    final deniedTasks = _tasks.where((t) => t.isDenied).length;

    return Column(
      children: [
        // Summary cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Incomplete',
                  incompleteTasks.toString(),
                  Colors.orange,
                  Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'Completed',
                  completedTasks.toString(),
                  Colors.blue,
                  Icons.assignment_turned_in,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'Approved',
                  approvedTasks.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ),
        
        // Task list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTasks,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                
                Color statusColor;
                if (task.isIncomplete) {
                  statusColor = Colors.orange;
                } else if (task.isCompleted) {
                  statusColor = Colors.blue;
                } else if (task.isApproved) {
                  statusColor = Colors.green;
                } else if (task.isDenied) {
                  statusColor = Colors.red;
                } else {
                  statusColor = Colors.grey;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor,
                      child: Text(
                        task.workerName?.substring(0, 1).toUpperCase() ?? 'W',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Worker: ${task.workerName ?? 'Unknown'}'),
                    trailing: Container(
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.description),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Start: ${_formatDate(task.startDate)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.event, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'End: ${_formatDate(task.endDate)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            if (task.completedAt != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Completed: ${_formatDate(task.completedAt!)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                            if (task.supervisorComment != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Supervisor Comment:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(task.supervisorComment!, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                            // Show approve/deny buttons for completed tasks
                            if (task.isCompleted) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showDenyTaskDialog(task),
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      label: const Text('Deny'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _approveTask(task),
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            // Show edit/delete buttons for approved or denied tasks
                            if (task.isApproved || task.isDenied) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _deleteTask(task),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      label: const Text('Delete'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => task.isApproved 
                                          ? _showDenyTaskDialog(task)
                                          : _approveTask(task),
                                      icon: Icon(task.isApproved ? Icons.cancel : Icons.check_circle),
                                      label: Text(task.isApproved ? 'Change to Deny' : 'Change to Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: task.isApproved ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            // Delete button for incomplete tasks
                            if (task.isIncomplete) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _deleteTask(task),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Delete Task'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  Future<void> _approveTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Task'),
        content: Text('Approve task "${task.title}" completed by ${task.workerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.updateTask(task.id, 'approved');
        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task approved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadTasks();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to approve task'),
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

  Future<void> _showDenyTaskDialog(Task task) async {
    final commentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deny Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deny task "${task.title}" by ${task.workerName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Explain why the task is denied...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deny'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final response = await _apiService.updateTask(
          task.id,
          'denied',
          supervisorComment: commentController.text.isNotEmpty ? commentController.text : null,
        );
        
        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task denied'),
                backgroundColor: Colors.orange,
              ),
            );
            _loadTasks();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to deny task'),
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

  Future<void> _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete task "${task.title}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.deleteTask(task.id);
        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadTasks();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to delete task'),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final departmentName = authProvider.currentUser?.departmentName ?? 'No Department';

    return ExitConfirmationWrapper(
      child: Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Supervisor Dashboard', style: TextStyle(fontSize: 18)),
            Text(
              departmentName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
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
          Expanded(child: _buildTasksList()),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[100],
            child: const VanillaBranding(compact: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Assign Task'),
      ),
      ),
    );
  }
}
