import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboards/applicant_dashboard.dart';
import 'screens/dashboards/worker_dashboard.dart';
import 'screens/dashboards/supervisor_dashboard.dart';
import 'screens/dashboards/admin_dashboard.dart';
import 'screens/admin/manage_jobs_screen.dart';
import 'screens/admin/manage_departments_screen.dart';
import 'screens/admin/manage_supervisors_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authProvider = AuthProvider();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Log out when app is paused (closed/backgrounded)
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _authProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp(
        title: 'County Worker Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/manage-jobs': (context) => const ManageJobsScreen(),
          '/manage-departments': (context) => const ManageDepartmentsScreen(),
          '/manage-supervisors': (context) => const ManageSupervisorsScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuth();
    setState(() {
      _isChecking = false;
    });
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Route based on user role
        final user = authProvider.currentUser;
        if (user == null) {
          return const LoginScreen();
        }

        switch (user.role) {
          case 'applicant':
            return const ApplicantDashboard();
          case 'worker':
            return const WorkerDashboard();
          case 'supervisor':
            return const SupervisorDashboard();
          case 'admin':
            return const AdminDashboard();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
