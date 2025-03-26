import 'package:flutter/material.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Transactions Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const Text(
          'View recent transactions and analyze your spending patterns.',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Recent Transaction: \$XXX'),
            subtitle: const Text('Placeholder for recent transaction details.'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Monthly Expenses'),
            subtitle: const Text('Placeholder for expense summary chart.'),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Implement sync or add transaction action
          },
          icon: const Icon(Icons.sync),
          label: const Text('Sync Transactions'),
        ),
      ],
    );
  }
}