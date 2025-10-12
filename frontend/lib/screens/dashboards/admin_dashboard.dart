import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../models/job.dart';
import '../../models/payment.dart';
import '../../models/user.dart' as models;
import '../../models/department.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/vanilla_branding.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  List<Application> _applications = [];
  List<Job> _jobs = [];
  List<Payment> _payments = [];
  List<models.User> _users = [];
  List<Department> _departments = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  
  // Search controllers
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _jobSearchController = TextEditingController();
  final TextEditingController _paymentSearchController = TextEditingController();
  final TextEditingController _applicationSearchController = TextEditingController();
  
  // Filtered lists
  List<models.User> _filteredUsers = [];
  List<Job> _filteredJobs = [];
  List<Payment> _filteredPayments = [];
  List<Application> _filteredApplications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadApplications(),
      _loadJobs(),
      _loadPayments(),
      _loadUsers(),
      _loadDepartments(),
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
      print('Error loading departments: $e');
    }
  }

  Future<void> _loadApplications() async {
    try {
      final response = await _apiService.getApplications();
      if (response['status'] == 'success') {
        setState(() {
          _applications = (response['applications'] as List)
              .map((app) => Application.fromJson(app))
              .toList();
          _filteredApplications = _applications;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading applications: $e')),
        );
      }
    }
  }

  Future<void> _loadJobs() async {
    try {
      final response = await _apiService.getJobs(status: 'all');
      if (response['status'] == 'success') {
        setState(() {
          _jobs = (response['jobs'] as List)
              .map((job) => Job.fromJson(job))
              .toList();
          _filteredJobs = _jobs;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading jobs: $e')),
        );
      }
    }
  }

  Future<void> _loadPayments() async {
    try {
      final response = await _apiService.getPayments();
      if (response['status'] == 'success') {
        setState(() {
          _payments = (response['payments'] as List)
              .map((payment) => Payment.fromJson(payment))
              .toList();
          _filteredPayments = _payments;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    }
  }

  Future<void> _loadUsers() async {
    try {
      final response = await _apiService.getUsers();
      if (response['status'] == 'success') {
        setState(() {
          _users = (response['users'] as List)
              .map((user) => models.User.fromJson(user))
              .where((user) => user.role != 'admin') // Hide admin users
              .toList();
          _filteredUsers = _users;
        });
        print('✅ Loaded ${_users.length} users');
      }
    } catch (e) {
      print('❌ Error loading users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _updateApplicationStatus(Application application, String status) async {
    // If accepting, show dialog to collect salary and department
    if (status == 'accepted') {
      await _showAcceptApplicationDialog(application);
      return;
    }
    
    // For rejection, proceed directly
    try {
      final response = await _apiService.updateApplication(application.id, status);
      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application $status successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadApplications();
          _loadUsers(); // Refresh users list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to update application'),
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

  Future<void> _showAcceptApplicationDialog(Application application) async {
    final salaryController = TextEditingController();
    int? selectedDepartmentId;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Accept Application'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Applicant: ${application.applicantName}'),
                Text('Job: ${application.jobTitle}'),
                const SizedBox(height: 20),
                TextField(
                  controller: salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Salary *',
                    hintText: 'e.g., 25000',
                    prefixText: 'KES ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedDepartmentId,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    border: OutlineInputBorder(),
                  ),
                  items: _departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept.id,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDepartmentId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (salaryController.text.isEmpty || selectedDepartmentId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );

    if (result == true && salaryController.text.isNotEmpty && selectedDepartmentId != null) {
      try {
        final salary = double.parse(salaryController.text);
        final response = await _apiService.updateApplication(
          application.id,
          'accepted',
          salary: salary,
          departmentId: selectedDepartmentId,
        );
        
        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Application accepted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadApplications();
            _loadUsers(); // Refresh users list
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to accept application'),
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

  Future<void> _updatePaymentStatus(Payment payment, String status) async {
    // If marking as paid, show dialog to confirm/edit amount
    if (status == 'paid') {
      await _showProcessPaymentDialog(payment);
      return;
    }
    
    try {
      final response = await _apiService.updatePayment(payment.id, status: status);
      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment marked as $status!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPayments();
          _loadUsers(); // Refresh to update salary balances
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to update payment'),
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

  Future<void> _showProcessPaymentDialog(Payment payment) async {
    final amountController = TextEditingController(text: payment.amount.toString());
    
    // Find worker to show salary balance
    final worker = _users.firstWhere(
      (u) => u.id == payment.workerId,
      orElse: () => models.User(
        id: 0,
        fullName: 'Unknown',
        email: '',
        role: 'worker',
      ),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Worker: ${payment.workerName}'),
              if (payment.taskTitle != null) Text('Task: ${payment.taskTitle}'),
              const SizedBox(height: 8),
              if (worker.salary != null) ...[
                Text('Monthly Salary: KES ${worker.salary!.toStringAsFixed(2)}'),
                Text(
                  'Current Balance: KES ${worker.salaryBalance?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (worker.salaryBalance ?? 0) > 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount *',
                  hintText: 'e.g., 5000',
                  prefixText: 'KES ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              if (worker.salaryBalance != null && amountController.text.isNotEmpty)
                Text(
                  'New Balance: KES ${(worker.salaryBalance! - (double.tryParse(amountController.text) ?? 0)).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter payment amount')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Process Payment'),
          ),
        ],
      ),
    );

    if (result == true && amountController.text.isNotEmpty) {
      try {
        final amount = double.parse(amountController.text);
        final response = await _apiService.updatePayment(
          payment.id,
          amount: amount,
          status: 'paid',
        );
        
        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment processed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadPayments();
            _loadUsers(); // Refresh to update salary balances
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to process payment'),
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

  Widget _buildDashboardOverview() {
    final pendingApplications = _applications.where((a) => a.isPending).length;
    final acceptedApplications = _applications.where((a) => a.isAccepted).length;
    final openJobs = _jobs.where((j) => j.isOpen).length;
    final unpaidPayments = _payments.where((p) => p.isUnpaid).length;
    final totalUnpaid = _payments
        .where((p) => p.isUnpaid)
        .fold<double>(0, (sum, p) => sum + p.amount);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Statistics cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Applications',
                  pendingApplications.toString(),
                  Colors.orange,
                  Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Approved Workers',
                  acceptedApplications.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Open Jobs',
                  openJobs.toString(),
                  Colors.blue,
                  Icons.work,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending Payments',
                  unpaidPayments.toString(),
                  Colors.red,
                  Icons.payment,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  const Text(
                    'Total Unpaid Amount',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KES ${totalUnpaid.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          ListTile(
            leading: const Icon(Icons.assignment, color: Colors.orange),
            title: const Text('Review Applications'),
            trailing: pendingApplications > 0
                ? CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 12,
                    child: Text(
                      pendingApplications.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  )
                : null,
            onTap: () {
              setState(() => _selectedIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.red),
            title: const Text('Process Payments'),
            trailing: unpaidPayments > 0
                ? CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 12,
                    child: Text(
                      unpaidPayments.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  )
                : null,
            onTap: () {
              setState(() => _selectedIndex = 2);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline, color: Colors.blue),
            title: const Text('Manage Jobs'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/manage-jobs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.business, color: Colors.purple),
            title: const Text('Manage Departments'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/manage-departments');
            },
          ),
          ListTile(
            leading: const Icon(Icons.supervisor_account, color: Colors.teal),
            title: const Text('Manage Supervisors'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/manage-supervisors');
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: VanillaBranding(compact: true),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    final pendingApps = _filteredApplications.where((a) => a.isPending).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _applicationSearchController,
            decoration: InputDecoration(
              hintText: 'Search applications by name, job, or status...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _applicationSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _applicationSearchController.clear();
                        _filterApplications('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterApplications,
          ),
        ),
        if (pendingApps.isEmpty)
          const Expanded(
            child: Center(child: Text('No pending applications')),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadApplications,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pendingApps.length,
                itemBuilder: (context, index) {
                  final application = pendingApps[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          application.applicantName?.substring(0, 1).toUpperCase() ?? 'A',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              application.applicantName ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              application.applicantEmail ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.work, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          application.jobTitle ?? 'Unknown Job',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(application.department ?? 'Unknown Department'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _updateApplicationStatus(application, 'rejected'),
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateApplicationStatus(application, 'accepted'),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentsList() {
    final unpaidPayments = _filteredPayments.where((p) => p.isUnpaid).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _paymentSearchController,
            decoration: InputDecoration(
              hintText: 'Search payments by worker name or status...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _paymentSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _paymentSearchController.clear();
                        _filterPayments('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterPayments,
          ),
        ),
        if (unpaidPayments.isEmpty)
          const Expanded(
            child: Center(child: Text('No pending payments')),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPayments,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: unpaidPayments.length,
                itemBuilder: (context, index) {
                  final payment = unpaidPayments[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.payment, color: Colors.orange, size: 40),
              title: Text(
                payment.workerName ?? 'Unknown Worker',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (payment.taskTitle != null)
                    Text('Task: ${payment.taskTitle}'),
                  Text('Amount: KES ${payment.amount.toStringAsFixed(2)}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _updatePaymentStatus(payment, 'paid'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Mark Paid'),
              ),
            ),
          );
        },
      ),
            ),
          ),
      ],
    );
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.fullName.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()) ||
            user.role.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _filterJobs(String query) {
    setState(() {
      _filteredJobs = _jobs.where((job) {
        return job.title.toLowerCase().contains(query.toLowerCase()) ||
            job.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _filterPayments(String query) {
    setState(() {
      _filteredPayments = _payments.where((payment) {
        return (payment.workerName?.toLowerCase() ?? '').contains(query.toLowerCase()) ||
            payment.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _filterApplications(String query) {
    setState(() {
      _filteredApplications = _applications.where((app) {
        return (app.applicantName?.toLowerCase() ?? '').contains(query.toLowerCase()) ||
            (app.jobTitle?.toLowerCase() ?? '').contains(query.toLowerCase()) ||
            app.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _buildDashboardOverview();
        break;
      case 1:
        body = _buildApplicationsList();
        break;
      case 2:
        body = _buildPaymentsList();
        break;
      case 3:
        body = _buildUsersList();
        break;
      default:
        body = _buildDashboardOverview();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // If not on overview tab, go back to overview
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }
        
        // If on overview tab, show exit confirmation
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        
        if (shouldExit == true && mounted) {
          // Exit the app
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
            icon: const Icon(Icons.lock),
            tooltip: 'Change Password',
            onPressed: _showChangePasswordDialog,
          ),
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
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _userSearchController,
            decoration: InputDecoration(
              hintText: 'Search users by name, email, or role...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _userSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _userSearchController.clear();
                        _filterUsers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterUsers,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUsers,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRoleColor(user.role),
                child: Text(
                  user.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(user.email),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (user.departmentName != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.business, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          user.departmentName!,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Manage User',
                    onPressed: () => _showUserManagementDialog(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete User',
                    onPressed: () => _deleteUser(user),
                  ),
                ],
              ),
              onTap: () => _showUserManagementDialog(user),
            ),
          );
        },
      ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'supervisor':
        return Colors.blue;
      case 'worker':
        return Colors.green;
      case 'applicant':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showUserManagementDialog(models.User user) async {
    final salaryController = TextEditingController(
      text: user.salary?.toString() ?? '',
    );
    final paymentAmountController = TextEditingController();
    final newPasswordController = TextEditingController();
    int? selectedDepartmentId = user.departmentId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Manage ${user.fullName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                Text('Email: ${user.email}'),
                Text('Role: ${user.role.toUpperCase()}'),
                const Divider(height: 24),
                
                // Password Reset
                const Text(
                  'Reset Password',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter new password for user',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (newPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a new password')),
                      );
                      return;
                    }
                    
                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password must be at least 6 characters')),
                      );
                      return;
                    }
                    
                    try {
                      final response = await _apiService.updateUser(
                        user.id,
                        {'password': newPasswordController.text},
                      );
                      
                      if (mounted && response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        newPasswordController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message'] ?? 'Failed to reset password'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('Reset Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                const Divider(height: 24),
                
                // Salary Management (for workers and supervisors)
                if (user.role == 'worker' || user.role == 'supervisor') ...[
                  const Text(
                    'Salary Management',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: salaryController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Salary',
                      prefixText: 'KES ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  if (user.salaryBalance != null)
                    Text(
                      'Current Balance: KES ${user.salaryBalance!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: user.salaryBalance! > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (salaryController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter salary amount')),
                        );
                        return;
                      }
                      
                      try {
                        final salary = double.parse(salaryController.text);
                        final response = await _apiService.updateUser(
                          user.id,
                          {'salary': salary},
                        );
                        
                        if (mounted && response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Salary updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadUsers();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Update Salary'),
                  ),
                  const Divider(height: 24),
                ],
                
                // Department Management (for workers and supervisors)
                if (user.role == 'worker' || user.role == 'supervisor') ...[
                  const Text(
                    'Department',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedDepartmentId,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    items: _departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept.id,
                        child: Text(dept.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartmentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (selectedDepartmentId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a department')),
                        );
                        return;
                      }
                      
                      try {
                        final response = await _apiService.updateUser(
                          user.id,
                          {'department_id': selectedDepartmentId},
                        );
                        
                        if (mounted && response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Department updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadUsers();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.business),
                    label: const Text('Update Department'),
                  ),
                  const Divider(height: 24),
                ],
                
                // Payment (for workers and supervisors)
                if (user.role == 'worker' || user.role == 'supervisor') ...[
                  const Text(
                    'Make Payment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: paymentAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Payment Amount',
                      prefixText: 'KES ',
                      border: OutlineInputBorder(),
                      hintText: 'Enter amount to pay',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (paymentAmountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter payment amount')),
                        );
                        return;
                      }
                      
                      try {
                        final amount = double.parse(paymentAmountController.text);
                        
                        // Create payment record
                        final response = await _apiService.createPayment({
                          'worker_id': user.id,
                          'amount': amount,
                          'description': 'Direct payment from admin',
                        });
                        
                        if (mounted && response['status'] == 'success') {
                          // Immediately mark as paid
                          final paymentId = response['payment']['id'];
                          await _apiService.updatePayment(
                            paymentId,
                            amount: amount,
                            status: 'paid',
                          );
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment processed successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadUsers();
                          _loadPayments();
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Process Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(models.User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
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
        final response = await _apiService.deleteUser(user.id);
        if (response['status'] == 'success' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
          _loadUsers();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to delete user')),
          );
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

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Your Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
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
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }

              try {
                final response = await _apiService.changePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'])),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _resetUserPassword(models.User user) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password for ${user.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
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
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }

              try {
                final response = await _apiService.resetUserPassword(
                  userId: user.id,
                  newPassword: newPasswordController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'])),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }
}
