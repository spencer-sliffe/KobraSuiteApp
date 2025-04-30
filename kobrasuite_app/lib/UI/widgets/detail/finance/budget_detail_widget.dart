// lib/UI/nav/overlays/details/budget_detail_sheet.dartimport 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/model_kind_enum.dart';
import '../../../../providers/finance/budget_provider.dart';
import '../../../nav/providers/detail_delagate_registry.dart';
import '../../../nav/providers/navigation_store.dart';
import 'package:flutter/material.dart';

class BudgetDetailSheet extends StatelessWidget {
  final int id;
  const BudgetDetailSheet({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final budget = context.select<BudgetProvider, dynamic>((p) => p.byId(id));
    if (budget == null) return const Center(child: CircularProgressIndicator());

    final theme = Theme.of(context);
    final spent = budget.totalAmount ?? 0.0;
    final remaining = budget.totalAmount - spent;
    final double remainingPercent = ((remaining / budget.totalAmount).clamp(0.0, 1.0)) as double;

    return Scaffold(
      appBar: AppBar(
        title: Text(budget.name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.read<NavigationStore>().closeDetail(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allocated', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text('\$${budget.totalAmount.toStringAsFixed(2)}', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: (1.0 - remainingPercent).clamp(0.0, 1.0)),                  const SizedBox(height: 8),
                  Text('Remaining: \$${remaining.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void register() {
    DetailDelegateRegistry.register(
      ModelKind.budget,
          (_, t) => BudgetDetailSheet(id: t.id),
    );
  }
}