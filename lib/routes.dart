import 'package:flutter/material.dart';
import 'package:agpop/screens/splash_screen.dart';
import 'package:agpop/screens/auth/login_screen.dart';
import 'package:agpop/screens/auth/reset_password_screen.dart';
import 'package:agpop/screens/home/home_screen.dart';
import 'package:agpop/screens/admin/position_screen.dart';
import 'package:agpop/screens/admin/task_screen.dart';
import 'package:agpop/screens/admin/user_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String positions = '/admin/positions';
  static const String tasks = '/admin/tasks'; // This is your tasks route
  static const String users = '/admin/users';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    resetPassword: (context) => const ResetPasswordScreen(),
    home: (context) => const HomeScreen(),
    positions: (context) => const PositionScreen(),
    tasks: (context) {
      final initialTab = ModalRoute.of(context)?.settings.arguments as String?;
      return TaskScreen(initialTab: initialTab);
    },
    users: (context) => const UserScreen(),
  };
}