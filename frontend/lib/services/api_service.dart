import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'https://countyworker-system-production.up.railway.app';

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save token
  Future<void> saveToken(String token) async {
    print('💾 Saving token: ${token.substring(0, 20)}...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    final saved = prefs.getString('auth_token');
    print('✅ Token saved successfully: ${saved != null}');
  }

  // Delete token
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    print('🔑 Token retrieved: ${token != null ? "YES (${token.substring(0, 20)}...)" : "NO"}');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle HTTP response with better error handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('📡 Response status: ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('❌ JSON decode error: $e');
        return {'status': 'error', 'message': 'Invalid response format'};
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        return errorBody;
      } catch (e) {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}'
        };
      }
    }
  }

  // Wrapper for HTTP requests with timeout and error handling
  Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() request,
    {String operation = 'Request'}
  ) async {
    try {
      final response = await request().timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      print('❌ $operation error: $e');
      return {'status': 'error', 'message': 'Network error: ${e.toString()}'};
    }
  }

  // AUTH ENDPOINTS
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
        'email': email,
        'password': password,
      }),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Signup error: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login for: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final result = _handleResponse(response);
      print('📥 Login response: ${result['status']}');
      if (result['token'] != null) {
        print('🎫 Token received: ${result['token'].substring(0, 20)}...');
      }
      return result;
    } catch (e) {
      print('❌ Login error: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Get profile error: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  // JOB ENDPOINTS
  Future<Map<String, dynamic>> getJobs({String status = 'open'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/jobs?status=$status'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Get jobs error: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required int departmentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/jobs'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'department_id': departmentId,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateJob(int jobId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/jobs/$jobId'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteJob(int jobId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/jobs/$jobId'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  // APPLICATION ENDPOINTS
  Future<Map<String, dynamic>> getApplications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/applications'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> applyForJob(int jobId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/applications'),
      headers: await _getHeaders(),
      body: jsonEncode({'job_id': jobId}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateApplication(
    int applicationId,
    String status, {
    double? salary,
    int? departmentId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/applications/$applicationId'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'status': status,
        if (salary != null) 'salary': salary,
        if (departmentId != null) 'department_id': departmentId,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteApplication(int applicationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/applications/$applicationId'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  // TASK ENDPOINTS
  Future<Map<String, dynamic>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/tasks'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required int assignedTo,
    required String startDate,
    required String endDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tasks'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'assigned_to': assignedTo,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateTask(
    int taskId,
    String progressStatus, {
    String? supervisorComment,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/tasks/$taskId'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'progress_status': progressStatus,
        if (supervisorComment != null) 'supervisor_comment': supervisorComment,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteTask(int taskId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/tasks/$taskId'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  // PAYMENT ENDPOINTS
  Future<Map<String, dynamic>> getPayments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/payments'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updatePayment(
    int paymentId, {
    double? amount,
    String? status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/payments/$paymentId'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (amount != null) 'amount': amount,
        if (status != null) 'status': status,
      }),
    );

    return jsonDecode(response.body);
  }

  // CONTRACT ENDPOINTS
  Future<Map<String, dynamic>> getContracts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/contracts'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  // DEPARTMENT ENDPOINTS
  Future<Map<String, dynamic>> getDepartments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/departments'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getDepartmentWorkers(int departmentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/departments/$departmentId/workers'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createDepartment({
    required String name,
    int? supervisorId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/departments'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        if (supervisorId != null) 'supervisor_id': supervisorId,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateDepartment(int departmentId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/departments/$departmentId'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteDepartment(int departmentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/departments/$departmentId'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  // Get all users (for admin to assign supervisors)
  Future<Map<String, dynamic>> getUsers({String? role}) async {
    String url = '$baseUrl/api/users';
    if (role != null) {
      url += '?role=$role';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: await _getHeaders(),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/change-password'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> resetUserPassword({
    required int userId,
    required String newPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$userId/reset-password'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'new_password': newPassword,
      }),
    );

    return jsonDecode(response.body);
  }
}
