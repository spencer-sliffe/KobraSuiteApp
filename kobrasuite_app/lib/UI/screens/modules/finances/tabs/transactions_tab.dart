import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/models/finance/transaction.dart' as finance_tx;
import 'package:kobrasuite_app/providers/finance/transaction_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({Key? key}) : super(key: key);

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab>
    with AutomaticKeepAliveClientMixin {
  late final ControlBarButtonModel _addTransactionButton;

  @override
  bool get wantKeepAlive => false; // Force disposal

  @override
  void initState() {
    super.initState();
    _addTransactionButton = ControlBarButtonModel(
      icon: Icons.add,
      label: 'Add Transaction',
      onPressed: _showCreateTransactionDialog,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ControlBarProvider>().addEphemeralButton(_addTransactionButton);
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    context.read<ControlBarProvider>().removeEphemeralButton(_addTransactionButton);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final txProvider = context.watch<TransactionProvider>();
    final isLoading = txProvider.isLoading;
    final error = txProvider.errorMessage;
    final transactions = txProvider.transactions;

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
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final finance_tx.Transaction tx = transactions[index];
                  return ListTile(
                    title: Text('${tx.transactionType} - \$${tx.amount.toStringAsFixed(2)}'),
                    subtitle: Text('Date: ${tx.date} | ID: ${tx.id}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => txProvider.deleteTransaction(tx.id),
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  void _showCreateTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddTransactionDialog(),
    );
  }
}

class _AddTransactionDialog extends StatefulWidget {
  const _AddTransactionDialog({Key? key}) : super(key: key);

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'EXPENSE';
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final txProvider = context.read<TransactionProvider>();
      await txProvider.createTransaction(
        transactionType: _selectedType,
        amount: double.parse(_amountCtrl.text),
        description: _descCtrl.text,
        dateIso: _selectedDate!.toIso8601String().split('T').first,
      );
      if (mounted) Navigator.pop(context);
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
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'EXPENSE', child: Text('Expense')),
                  DropdownMenuItem(value: 'INCOME', child: Text('Income')),
                  DropdownMenuItem(value: 'TRANSFER', child: Text('Transfer')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
                decoration: const InputDecoration(labelText: 'Transaction Type'),
              ),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(
                  _selectedDate == null ? 'Select Date' : _selectedDate!.toLocal().toString().split(' ')[0],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveTransaction, child: const Text('Save')),
      ],
    );
  }
}