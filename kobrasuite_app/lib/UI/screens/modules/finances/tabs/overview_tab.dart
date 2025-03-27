// lib/modules/finances/tabs/overview_tab.dart

import 'package:flutter/material.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Financial Overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Text(
          'Finances, net worth, '
              'and quick links to important actions.',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Net Worth: \$XX,XXX'),
            subtitle: const Text('Combines bank balances, stocks, budgets, etc.'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Monthly Cash Flow'),
            subtitle: const Text('Placeholder chart or numeric summary.'),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sync),
          label: const Text('Sync Accounts'),
        ),
      ],
    );
  }
}