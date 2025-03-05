import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/models/finance/budget.dart';
import 'package:kobrasuite_app/providers/finance/budget_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';

class BudgetsTab extends StatefulWidget {
  const BudgetsTab({Key? key}) : super(key: key);

  @override
  State<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends State<BudgetsTab>
    with AutomaticKeepAliveClientMixin {
  late final ControlBarButtonModel _addBudgetButton;

  @override
  bool get wantKeepAlive => false; // Force disposal

  @override
  void initState() {
    super.initState();
    _addBudgetButton = ControlBarButtonModel(
      icon: Icons.add,
      label: 'Add Budget',
      onPressed: _showAddBudgetDialog,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ControlBarProvider>().addEphemeralButton(_addBudgetButton);
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  @override
  void dispose() {
    context.read<ControlBarProvider>().removeEphemeralButton(_addBudgetButton);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              padding: const EdgeInsets.all(16),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          if (!isLoading && error.isEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: budgets.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final Budget budget = budgets[index];
                  return ListTile(
                    title: Text('${budget.name} - \$${budget.totalAmount.toStringAsFixed(2)}'),
                    subtitle: Text(
                      'Active: ${budget.isActive ? 'Yes' : 'No'} | ${budget.startDate} to ${budget.endDate}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => budgetProvider.deleteBudget(budget.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddBudgetDialog(),
    );
  }
}

class _AddBudgetDialog extends StatefulWidget {
  const _AddBudgetDialog({Key? key}) : super(key: key);

  @override
  State<_AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<_AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newDate != null) {
      setState(() {
        if (isStart) {
          _startDate = newDate;
        } else {
          _endDate = newDate;
        }
      });
    }
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      final budgetProvider = context.read<BudgetProvider>();
      final success = await budgetProvider.createBudget(
        name: _nameCtrl.text,
        totalAmount: double.parse(_amountCtrl.text),
        startDate: _startDate!.toIso8601String().split('T').first,
        endDate: _endDate!.toIso8601String().split('T').first,
        isActive: _isActive,
      );
      if (success && mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(context, true),
                      child: Text(_startDate == null ? 'Select Start Date' : _startDate!.toLocal().toString().split(' ')[0]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(context, false),
                      child: Text(_endDate == null ? 'Select End Date' : _endDate!.toLocal().toString().split(' ')[0]),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveBudget, child: const Text('Save')),
      ],
    );
  }
}