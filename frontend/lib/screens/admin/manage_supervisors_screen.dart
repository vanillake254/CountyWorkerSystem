import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class ManageSupervisorsScreen extends StatefulWidget {
  const ManageSupervisorsScreen({super.key});

  @override
  State<ManageSupervisorsScreen> createState() => _ManageSupervisorsScreenState();
}

class _ManageSupervisorsScreenState extends State<ManageSupervisorsScreen> {
  final ApiService _apiService = ApiService();
  List<User> _supervisors = [];
  List<User> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadSupervisors(),
      _loadAllUsers(),
    ]);
    setState(() => _isLoading = false);
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

  Future<void> _loadAllUsers() async {
    try {
      final response = await _apiService.getUsers();
      if (response['status'] == 'success') {
        setState(() {
          _allUsers = (response['users'] as List)
              .map((user) => User.fromJson(user))
              .where((user) => user.role != 'admin') // Exclude admins
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _showPromoteDialog() async {
    final nonSupervisors = _allUsers
        .where((user) => user.role != 'supervisor')
        .toList();

    if (nonSupervisors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No users available to promote'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    User? selectedUser;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Promote to Supervisor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a user to promote to supervisor role:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<User>(
                value: selectedUser,
                decoration: const InputDecoration(
                  labelText: 'Select User',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: nonSupervisors.map((user) {
                  return DropdownMenuItem(
                    value: user,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedUser = value;
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
              onPressed: selectedUser == null
                  ? null
                  : () async {
                      try {
                        final response = await _apiService.updateUser(
                          selectedUser!.id,
                          {'role': 'supervisor'},
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User promoted to supervisor!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message'] ?? 'Failed to promote user'),
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
              child: const Text('Promote'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _demoteSupervisor(User supervisor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demote Supervisor'),
        content: Text(
            'Are you sure you want to demote "${supervisor.fullName}" from supervisor to worker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Demote'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.updateUser(
          supervisor.id,
          {'role': 'worker'},
        );

        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Supervisor demoted to worker!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to demote supervisor'),
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
        title: const Text('Manage Supervisors'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _supervisors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.supervisor_account,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No supervisors yet'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _showPromoteDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Promote User'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _supervisors.length,
                      itemBuilder: (context, index) {
                        final supervisor = _supervisors[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                supervisor.fullName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              supervisor.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(supervisor.email),
                                if (supervisor.departmentName != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.business,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        supervisor.departmentName!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'demote',
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_downward,
                                          size: 20, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('Demote to Worker',
                                          style: TextStyle(color: Colors.orange)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'demote') {
                                  _demoteSupervisor(supervisor);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPromoteDialog,
        icon: const Icon(Icons.add),
        label: const Text('Promote User'),
      ),
    );
  }
}
