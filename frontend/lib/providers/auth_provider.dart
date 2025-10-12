import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Sign up
  Future<bool> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.signup(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (response['status'] == 'success') {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Signup failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response['status'] == 'success') {
        // Save token
        await _apiService.saveToken(response['token']);
        
        // Set current user
        _currentUser = User.fromJson(response['user']);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load user profile
  Future<void> loadProfile() async {
    try {
      final response = await _apiService.getProfile();
      
      if (response['status'] == 'success') {
        _currentUser = User.fromJson(response['user']);
        notifyListeners();
      }
    } catch (e) {
      // Token might be invalid
      await logout();
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.deleteToken();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user has token on app start
  Future<bool> checkAuth() async {
    final token = await _apiService.getToken();
    if (token != null) {
      await loadProfile();
      return _currentUser != null;
    }
    return false;
  }
}
