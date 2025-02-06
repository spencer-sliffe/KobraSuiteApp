/// UI/screens/hq/hq_dashboard_screen.dart

import 'package:flutter/material.dart';

class HQDashboardScreen extends StatelessWidget {
  const HQDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Profile Dashboard', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Icon(Icons.videogame_asset, size: 100, color: Colors.white),
            const SizedBox(height: 16),
            Text('Wallet: \$1000', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Calendar Events, Notifications, Achievements', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}