import 'package:agpop/models/user_model.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmployeeHome extends StatelessWidget {
  final UserModel user;

  const EmployeeHome({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with user's name
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${user.name}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your tasks overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.subtitleTextColor,
                ),
              ),
            ],
          ),
        ),
        // Placeholder for task tabs or list
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment,
                  size: 64,
                  color: AppTheme.subtitleTextColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your tasks will appear here.',
                  style: TextStyle(
                    color: AppTheme.subtitleTextColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}