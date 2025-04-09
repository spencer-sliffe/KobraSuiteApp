import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import your BudgetProvider if available. For example:
// import '../../../providers/finance/budget_provider.dart';

enum AddBudgetState { initial, adding, added }

class AddBudgetBottomSheet extends StatefulWidget {
  const AddBudgetBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddBudgetBottomSheet> createState() => _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends State<AddBudgetBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _budgetNameController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();

  bool _isActive = true;
  AddBudgetState _state = AddBudgetState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _budgetNameController.dispose();
    _totalAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  Future<void> _addBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddBudgetState.adding;
      _errorFeedback = "";
    });

    // Simulate a service call. Replace the following with your actual provider call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual service response.

    if (success) {
      setState(() {
        _state = AddBudgetState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add budget.';
        _state = AddBudgetState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddBudgetState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding budget...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddBudgetState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Budget added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Budget Name
            TextFormField(
              controller: _budgetNameController,
              decoration: const InputDecoration(labelText: 'Budget Name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a budget name'
                  : null,
            ),
            const SizedBox(height: 12),
            // Total Amount
            TextFormField(
              controller: _totalAmountController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter total amount';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Start Date
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter start date' : null,
            ),
            const SizedBox(height: 12),
            // End Date
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter end date' : null,
            ),
            const SizedBox(height: 12),
            // Active toggle: you can use a Switch form field or simple Checkbox.
            Row(
              children: [
                const Text('Active:'),
                Switch(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Categories (optional)
            TextFormField(
              controller: _categoriesController,
              decoration: const InputDecoration(
                labelText: 'Categories (comma-separated)',
              ),
            ),
            if (_errorFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorFeedback,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == AddBudgetState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddBudgetState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addBudget,
          child: const Text('Add Budget'),
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add New Budget', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActions(),
            ),
          ],
        ),
      ),
    );
  }
}