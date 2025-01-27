import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder: list of notifications
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Notifications Module',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // just a placeholder
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text('Notification #$index'),
                    subtitle: const Text('This is a placeholder notification.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}