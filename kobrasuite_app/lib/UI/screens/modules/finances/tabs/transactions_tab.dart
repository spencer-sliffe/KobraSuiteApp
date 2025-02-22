import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/providers/finance/transaction_provider.dart';
import 'package:kobrasuite_app/models/finance/transaction.dart' as finance_tx;

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({Key? key}) : super(key: key);

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16.0),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          if (!isLoading && error.isEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final finance_tx.Transaction tx = transactions[index];
                  return ListTile(
                    title: Text('${tx.transactionType} - \$${tx.amount}'),
                    subtitle: Text('Date: ${tx.date} | ID: ${tx.id}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await txProvider.deleteTransaction(tx.id);
                      },
                    ),
                  );
                },
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final typeCtrl = TextEditingController();
        final amountCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        final dateCtrl = TextEditingController(text: '2023-01-01');
        return AlertDialog(
          title: const Text('Create Transaction'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Transaction Type')),
                TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
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
                final txProvider = context.read<TransactionProvider>();
                await txProvider.createTransaction(
                  transactionType: typeCtrl.text,
                  amount: double.tryParse(amountCtrl.text) ?? 0.0,
                  description: descCtrl.text,
                  dateIso: dateCtrl.text,
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