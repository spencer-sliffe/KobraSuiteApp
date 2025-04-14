// lib/modules/finances/widgets/cards/budget_category_card.dart

import 'package:flutter/material.dart';
import '../../../../models/finance/budget_category.dart';

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategory category;
  final VoidCallback? onDelete;

  const BudgetCategoryCard({
    Key? key,
    required this.category,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Optionally navigate to category details or editing page.
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // CircleAvatar for a quick visual representation
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  category.name.isNotEmpty
                      ? category.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Category details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category name
                    Text(
                      category.name,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Allocated amount
                    Text(
                      'Allocated: \$${category.allocatedAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    // Category type (e.g. EXPENSE, SAVINGS, OTHER)
                    Text(
                      'Type: ${category.categoryType}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Optional delete icon
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}