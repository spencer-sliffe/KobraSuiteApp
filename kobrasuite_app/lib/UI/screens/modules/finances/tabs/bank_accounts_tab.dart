import 'package:flutter/material.dart';

class BankAccountsTab extends StatelessWidget {
  const BankAccountsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Bank Accounts Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const Text(
          'Review your bank accounts and total balances, and access quick actions.',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Total Balance: \$XX,XXX'),
            subtitle: const Text('Sum of all bank account balances.'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Number of Accounts: X'),
            subtitle: const Text('Overview of your linked bank accounts.'),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {

          },
          icon: const Icon(Icons.sync),
          label: const Text('Sync Accounts'),
        ),
      ],
    );
  }
}