// lib/UI/widgets/bottomsheets/finance/add_transaction_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/finance/transaction_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddTransactionState { initial, adding, added }

class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  State<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _typeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _date;

  AddTransactionState _state = AddTransactionState.initial;
  String _error = '';

  @override
  void dispose() {
    _typeCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddTransactionState.adding;
      _error = '';
    });

    final ok = await context.read<TransactionProvider>().createTransaction(
      transactionType: _typeCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dateIso: _date?.toIso8601String().substring(0, 10),
    );

    setState(() {
      _state = ok ? AddTransactionState.added : AddTransactionState.initial;
      if (!ok) _error = 'Failed to add transaction.';
    });
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
            if (_state == AddTransactionState.adding)
              const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())
            else if (_state == AddTransactionState.added)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Transaction added.', style: Theme.of(context).textTheme.titleLarge),
              )
            else
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _typeCtrl,
                        decoration: const InputDecoration(labelText: 'Transaction type'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Amount'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter amount';
                          return double.tryParse(v.trim()) == null ? 'Enter number' : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(labelText: 'Description (optional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                        ),
                        controller: TextEditingController(text: _date == null ? '' : _date!.toIso8601String().substring(0, 10)),
                        validator: (_) => _date == null ? 'Pick a date' : null,
                      ),
                      if (_error.isNotEmpty)
                        Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_state != AddTransactionState.adding)
                  TextButton(onPressed: () => context.read<NavigationStore>().setAddTransactionActive(), child: const Text('Cancel')),
                if (_state == AddTransactionState.initial)
                  ElevatedButton(onPressed: _submit, child: const Text('Add Transaction')),
                if (_state == AddTransactionState.added)
                  ElevatedButton(onPressed: () => context.read<NavigationStore>().setAddTransactionActive(), child: const Text('Close')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}