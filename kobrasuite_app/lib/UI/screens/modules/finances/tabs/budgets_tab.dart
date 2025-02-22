import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/providers/finance/budget_provider.dart';
import 'package:kobrasuite_app/models/finance/budget.dart';

class BudgetsTab extends StatefulWidget {
  const BudgetsTab({Key? key}) : super(key: key);

  @override
  State<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends State<BudgetsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final isLoading = budgetProvider.isLoading;
    final error = budgetProvider.errorMessage;
    final budgets = budgetProvider.budgets;

    return Scaffold(
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          if (!isLoading && error.isEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final Budget budget = budgets[index];
                  return ListTile(
                    title: Text('${budget.name} - \$${budget.totalAmount}'),
                    subtitle: Text('Active: ${budget.isActive} | Start: ${budget.startDate} | End: ${budget.endDate}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await budgetProvider.deleteBudget(budget.id);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBudgetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController();
        final amountCtrl = TextEditingController();
        final startCtrl = TextEditingController(text: '2023-01-01');
        final endCtrl = TextEditingController(text: '2023-12-31');
        bool isActive = true;
        return AlertDialog(
          title: const Text('Create Budget'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Total Amount')),
                TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)')),
                TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)')),
                SwitchListTile(
                  title: const Text('Is Active?'),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final provider = context.read<BudgetProvider>();
                await provider.createBudget(
                  name: nameCtrl.text,
                  totalAmount: double.tryParse(amountCtrl.text) ?? 0.0,
                  startDate: startCtrl.text,
                  endDate: endCtrl.text,
                  isActive: isActive,
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}