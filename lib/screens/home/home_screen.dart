import 'package:agpop/models/user_model.dart';
import 'package:agpop/repositories/user_repository.dart';
import 'package:agpop/routes.dart';
import 'package:agpop/screens/home/admin_home_screen.dart';
import 'package:agpop/screens/home/employee_home_screen.dart';
import 'package:agpop/services/auth_service.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userRepository = UserRepository();
  final _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.getCurrentUser()?.uid;
      if (userId == null) {
        _handleAuthError();
        return;
      }

      final user = await _userRepository.getById(userId);

      if (user != null) {
        if (mounted) {
          setState(() {
            _currentUser = user;
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        _handleAuthError();
      }
    }
  }

  void _handleAuthError() async {
    await _authService.signOut(); // Use AuthService for sign out
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut(); // Use AuthService for sign out
    if (mounted) {
      // The StreamBuilder in main.dart will automatically redirect to LoginScreen
      // so we don't need `Navigator.pushReplacementNamed(AppRoutes.login);` here.
      // Simply popping current routes to ensure clean state
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    final isAdmin = _currentUser?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Panel' : 'My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Notifications will be implemented here
              debugPrint('Notifications tapped');
            },
          ),
          PopupMenuButton(
            icon: CircleAvatar(
                backgroundImage: null, // Placeholder, would use user.photoURL
                child: Text(_currentUser!.name.isNotEmpty
                    ? _currentUser!.name.substring(0, 1).toUpperCase()
                    : 'U' // Default for empty name
                )
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('My Profile'),
                onTap: () {
                  // Profile view will be implemented here
                  debugPrint('My Profile tapped');
                },
              ),
              PopupMenuItem(
                child: const Text('Sign Out'),
                onTap: _signOut,
              ),
            ],
          ),
        ],
      ),
      body: isAdmin
          ? AdminHome(user: _currentUser!)
          : EmployeeHome(user: _currentUser!),
    );
  }
}