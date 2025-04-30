// lib/UI/widgets/cards/finance/budget_card.dart
import 'package:flutter/material.dart';
import '../../../../../models/finance/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCard({super.key, required this.budget, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Total: \$${budget.totalAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}