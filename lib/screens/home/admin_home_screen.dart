import 'package:agpop/models/user_model.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  final UserModel user;

  const AdminHome({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user.name}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 8),
          Text(
            'Admin Dashboard',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.subtitleTextColor
            )
          ),
          const SizedBox(height: 24),

          Text(
            'Dashboard Metrics will go here.',
            style: Theme.of(context).textTheme.titleMedium
          ),
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.people_outline, color: AppTheme.primaryColor),
              title: const Text('User Count: [N/A]'),
              subtitle: const Text('Click to manage users'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
              }
            )
          ),
          const SizedBox(height: 32),
          Text(
            'Management Options',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 16)
        ]
      )
    );
  }
}