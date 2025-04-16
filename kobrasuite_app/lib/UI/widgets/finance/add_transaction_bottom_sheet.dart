import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nav/providers/navigation_store.dart';

enum AddTransactionState { initial, adding, added }

class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for fields.
  final TextEditingController _transactionTypeController =
  TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  AddTransactionState _state = AddTransactionState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _transactionTypeController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _addTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddTransactionState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call. Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual success state.

    if (success) {
      setState(() {
        _state = AddTransactionState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add transaction.';
        _state = AddTransactionState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddTransactionState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding transaction...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddTransactionState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Transaction added successfully.',
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
            // Transaction Type
            TextFormField(
              controller: _transactionTypeController,
              decoration:
              const InputDecoration(labelText: 'Transaction Type'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter transaction type' : null,
            ),
            const SizedBox(height: 12),
            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter amount';
                if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Description (optional)
            TextFormField(
              controller: _descriptionController,
              decoration:
              const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 12),
            // Date field (e.g., transaction date)
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Transaction Date (YYYY-MM-DD)',
              ),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter transaction date' : null,
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
    if (_state == AddTransactionState.added) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddTransactionActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddTransactionState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddTransactionActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addTransaction,
          child: const Text('Add Transaction'),
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
            Text('Add New Transaction', style: Theme.of(context).textTheme.headlineSmall),
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