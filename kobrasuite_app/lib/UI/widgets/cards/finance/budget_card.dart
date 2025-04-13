import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/finance/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onDelete;

  const BudgetCard({
    Key? key,
    required this.budget,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // You can format dates if needed; for now we use the raw strings.
    // final startDate = DateTime.tryParse(budget.startDate);
    // final endDate = DateTime.tryParse(budget.endDate);
    // final dateFormat = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Optionally navigate to budget details.
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar showing the first character of the budget name.
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  budget.name.isNotEmpty
                      ? budget.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Budget details.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget name.
                    Text(
                      budget.name,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Total amount formatted to two decimals.
                    Text(
                      'Total: \$${budget.totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    // Date range (you can add custom formatting if desired).
                    Text(
                      'From: ${budget.startDate} To: ${budget.endDate}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Optional delete button.
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