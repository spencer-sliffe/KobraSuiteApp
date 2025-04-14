import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/finance/budget_provider.dart';
import '../../../providers/finance/budget_category_provider.dart';
import '../../../models/finance/budget.dart';

enum AddBudgetCategoryState { initial, adding, added }

class AddBudgetCategoryBottomSheet extends StatefulWidget {
  const AddBudgetCategoryBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddBudgetCategoryBottomSheet> createState() =>
      _AddBudgetCategoryBottomSheetState();
}

class _AddBudgetCategoryBottomSheetState extends State<AddBudgetCategoryBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _allocatedAmountController = TextEditingController();
  String _categoryType = 'NECESSARY'; // Default type; adjust as needed.

  AddBudgetCategoryState _state = AddBudgetCategoryState.initial;
  String _errorFeedback = "";

  /// The currently selected budget in our dropdown
  Budget? _selectedBudget;

  @override
  void dispose() {
    _categoryNameController.dispose();
    _allocatedAmountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // (Optional) Load budgets if needed
    // You could also call `context.read<BudgetProvider>().loadBudgets()` here
    // if your budgets are not already loaded at this point.

    final budgetProvider = context.read<BudgetProvider>();
    // If budgets are already loaded, set the first one as selected by default.
    if (budgetProvider.budgets.isNotEmpty) {
      _selectedBudget = budgetProvider.budgets.first;
    }
  }

  Future<void> _addBudgetCategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBudget == null) {
      setState(() {
        _errorFeedback = 'Please select a budget.';
      });
      return;
    }

    setState(() {
      _state = AddBudgetCategoryState.adding;
      _errorFeedback = "";
    });

    final provider = context.read<BudgetCategoryProvider>();

    final success = await provider.createCategory(
      budgetId: _selectedBudget!.id,
      name: _categoryNameController.text.trim(),
      allocatedAmount: double.tryParse(
        _allocatedAmountController.text
            .replaceAll('\$', '')
            .trim(),
      ) ??
          0.0,
      categoryType: _categoryType,
    );

    if (success) {
      setState(() {
        _state = AddBudgetCategoryState.added;
      });
    } else {
      setState(() {
        _errorFeedback = (provider.errorMessage.isNotEmpty)
            ? provider.errorMessage
            : 'Failed to add budget category.';
        _state = AddBudgetCategoryState.initial;
      });
    }
  }

  Widget _buildContent(BuildContext context, List<Budget> budgets) {
    if (_state == AddBudgetCategoryState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding budget category...'),
            ],
          ),
        ),
      );
    }

    if (_state == AddBudgetCategoryState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Budget category added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    // Regular form
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
            // Budget Selector
            if (budgets.isNotEmpty)
              DropdownButtonFormField<Budget>(
                value: _selectedBudget,
                decoration: const InputDecoration(labelText: 'Select Budget'),
                items: budgets.map((budget) {
                  return DropdownMenuItem<Budget>(
                    value: budget,
                    child: Text(budget.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBudget = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a budget';
                  }
                  return null;
                },
              )
            else
              const Text('No budgets found. Please create a budget first.'),
            const SizedBox(height: 12),

            // Category Name
            TextFormField(
              controller: _categoryNameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter category name' : null,
            ),
            const SizedBox(height: 12),

            // Allocated Amount
            TextFormField(
              controller: _allocatedAmountController,
              decoration: const InputDecoration(labelText: 'Allocated Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter allocated amount';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Category Type Dropdown
            DropdownButtonFormField<String>(
              value: _categoryType,
              items: const [
                DropdownMenuItem(value: 'NECESSARY', child: Text('Necessary Expenses')),
                DropdownMenuItem(value: 'UNNECESSARY', child: Text('Unnecessary Expenses')),
                DropdownMenuItem(value: 'INVESTING', child: Text('Investing')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _categoryType = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Category Type'),
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
    if (_state == AddBudgetCategoryState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        )
      ];
    }

    if (_state == AddBudgetCategoryState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addBudgetCategory,
          child: const Text('Add Category'),
        ),
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    // Read budgets from provider
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final isLoadingBudgets = budgetProvider.isLoading;
        final budgets = budgetProvider.budgets;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: isLoadingBudgets
                ? const Center(child: CircularProgressIndicator())
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add New Budget Category',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                _buildContent(context, budgets),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildActions(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}