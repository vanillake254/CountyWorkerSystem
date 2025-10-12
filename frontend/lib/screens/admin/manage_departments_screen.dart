import 'package:flutter/material.dart';
import '../../models/department.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  State<ManageDepartmentsScreen> createState() => _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  final ApiService _apiService = ApiService();
  List<Department> _departments = [];
  List<User> _supervisors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadDepartments(),
      _loadSupervisors(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await _apiService.getDepartments();
      if (response['status'] == 'success') {
        setState(() {
          _departments = (response['departments'] as List)
              .map((dept) => Department.fromJson(dept))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading departments: $e')),
        );
      }
    }
  }

  Future<void> _loadSupervisors() async {
    try {
      final response = await _apiService.getUsers(role: 'supervisor');
      if (response['status'] == 'success') {
        setState(() {
          _supervisors = (response['users'] as List)
              .map((user) => User.fromJson(user))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading supervisors: $e')),
        );
      }
    }
  }

  Future<void> _showDepartmentDialog({Department? department}) async {
    final nameController = TextEditingController(text: department?.name ?? '');
    int? selectedSupervisorId = department?.supervisorId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(department == null ? 'Create Department' : 'Edit Department'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Department Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                value: selectedSupervisorId,
                decoration: const InputDecoration(
                  labelText: 'Supervisor (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No Supervisor'),
                  ),
                  ..._supervisors.map((supervisor) {
                    return DropdownMenuItem(
                      value: supervisor.id,
                      child: Text(supervisor.fullName),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedSupervisorId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter department name')),
                  );
                  return;
                }

                try {
                  Map<String, dynamic> response;
                  if (department == null) {
                    response = await _apiService.createDepartment(
                      name: nameController.text,
                      supervisorId: selectedSupervisorId,
                    );
                  } else {
                    response = await _apiService.updateDepartment(department.id, {
                      'name': nameController.text,
                      'supervisor_id': selectedSupervisorId,
                    });
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    if (response['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(department == null
                              ? 'Department created successfully!'
                              : 'Department updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadDepartments();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? 'Operation failed'),
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
              },
              child: Text(department == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDepartment(Department department) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete "${department.name}"?'),
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
        final response = await _apiService.deleteDepartment(department.id);
        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Department deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadDepartments();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to delete department'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Departments'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _departments.isEmpty
                  ? const Center(child: Text('No departments found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _departments.length,
                      itemBuilder: (context, index) {
                        final department = _departments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.business),
                            ),
                            title: Text(
                              department.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: department.supervisorName != null
                                ? Text('Supervisor: ${department.supervisorName}')
                                : const Text('No supervisor assigned',
                                    style: TextStyle(fontStyle: FontStyle.italic)),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showDepartmentDialog(department: department);
                                } else if (value == 'delete') {
                                  _deleteDepartment(department);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDepartmentDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Department'),
      ),
    );
  }
}
