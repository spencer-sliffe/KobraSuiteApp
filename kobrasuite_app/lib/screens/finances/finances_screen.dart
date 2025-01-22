import 'package:flutter/material.dart';

class FinancesScreen extends StatelessWidget {
  const FinancesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Finances Module',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: const Text('Bank Account #1'),
                    subtitle: const Text('\$1,200.00'),
                    onTap: () {
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text('Monthly Budget'),
                    subtitle: const Text('\$3,500 out of \$5,000 spent'),
                    onTap: () {
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}