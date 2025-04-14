import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:provider/provider.dart';
import '../../../providers/finance/transaction_provider.dart';
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

    final transactionProvider = context.read<TransactionProvider>();

    final transactionType = _transactionTypeController.text.trim();
    final rawAmount = _amountController.text.trim();
    final amount = double.tryParse(rawAmount) ?? 0.0;
    final description = _descriptionController.text.trim();
    final dateIso = _dateController.text.trim();

    final success = await transactionProvider.createTransaction(
      transactionType: transactionType,
      amount: amount,
      description: description.isNotEmpty ? description : null,
      dateIso: dateIso,
    );

    if (success) {
      setState(() {
        _state = AddTransactionState.added;
      });
    } else {
      setState(() {
        _errorFeedback = ((transactionProvider.errorMessage).isNotEmpty)
            ? transactionProvider.errorMessage
            : 'Failed to add transaction.';
        _state = AddTransactionState.initial;
      });
    }
  }

  /// Opens a calendar picker to set the date on the given controller.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1); // 1 year in the past
    final lastDate = DateTime(now.year + 1); // 1 year in the future

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate != null) {
      // Format as YYYY-MM-DD
      final year = pickedDate.year.toString().padLeft(4, '0');
      final month = pickedDate.month.toString().padLeft(2, '0');
      final day = pickedDate.day.toString().padLeft(2, '0');
      _dateController.text = '$year-$month-$day';
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
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$', // Shows the "$" symbol.
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter amount';
                final rawAmount = value.replaceAll('\$', '').trim();
                if (double.tryParse(rawAmount) == null) return 'Enter a valid number';
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
            // Date field with date picker
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _pickDate(),
              decoration: const InputDecoration(
                labelText: 'Transaction Date (YYYY-MM-DD)',
                suffixIcon: Icon(Icons.calendar_today),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddTransactionState.initial) {
      return [
        TextButton(
          onPressed: () => 
              context.read<NavigationStore>().setAddTransactionActive(),
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