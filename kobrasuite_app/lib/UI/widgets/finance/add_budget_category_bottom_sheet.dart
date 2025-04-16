import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nav/providers/navigation_store.dart';
// If you have a BudgetCategoryProvider or service, import it here.

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
  String _categoryType = 'EXPENSE'; // Default value.

  AddBudgetCategoryState _state = AddBudgetCategoryState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _categoryNameController.dispose();
    _allocatedAmountController.dispose();
    super.dispose();
  }

  Future<void> _addBudgetCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddBudgetCategoryState.adding;
      _errorFeedback = "";
    });

    // Simulate a service call with a delay.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual API/service call.

    if (success) {
      setState(() {
        _state = AddBudgetCategoryState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add budget category.';
        _state = AddBudgetCategoryState.initial;
      });
    }
  }

  Widget _buildContent() {
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
                if (value == null || value.trim().isEmpty) return 'Enter allocated amount';
                if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Category Type Dropdown
            DropdownButtonFormField<String>(
              value: _categoryType,
              items: const [
                DropdownMenuItem(value: 'EXPENSE', child: Text('EXPENSE')),
                DropdownMenuItem(value: 'SAVINGS', child: Text('SAVINGS')),
                DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
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
          onPressed: ()
          => context.read<NavigationStore>().setAddCategoryActive(),
          child: const Text('Close'),
        )
      ];
    }
    if (_state == AddBudgetCategoryState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddCategoryActive(),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add New Budget Category',
                style: Theme.of(context).textTheme.headlineSmall),
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