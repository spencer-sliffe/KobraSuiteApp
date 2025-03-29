// lib/modules/finances/tabs/budgets_tab.dart

import 'package:flutter/material.dart';

class BudgetsTab extends StatelessWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Budget Overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Text(
          'Manage your budgets, track allocations, and view financial trends.',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
            title: const Text('Total Budget'),
            subtitle: const Text('Aggregate of all budgets: \$45,000'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.show_chart, color: Colors.blue),
            title: const Text('Monthly Cash Flow'),
            subtitle: const Text('Placeholder chart or summary data'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.trending_up, color: Colors.orange),
            title: const Text('Budget Trends'),
            subtitle: const Text('Placeholder for trend analysis'),
          ),
        ),
      ],
    );
  }
}