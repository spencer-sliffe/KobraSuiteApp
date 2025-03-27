// lib/modules/finances/tabs/budget_categories_tab.dart

import 'package:flutter/material.dart';

class BudgetCategoriesTab extends StatelessWidget {
  const BudgetCategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Budget Categories', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: const Text('Rent'),
            subtitle: const Text('Allocated: \$900 / Spent: \$800'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Groceries'),
            subtitle: const Text('Allocated: \$300 / Spent: \$275'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),
          ),
        ),
        // ... more dummy categories ...
      ],
    );
  }
}