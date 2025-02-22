import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/providers/finance/bank_account_provider.dart';
import 'package:kobrasuite_app/models/finance/bank_account.dart';

class BankAccountsTab extends StatefulWidget {
  const BankAccountsTab({Key? key}) : super(key: key);

  @override
  State<BankAccountsTab> createState() => _BankAccountsTabState();
}

class _BankAccountsTabState extends State<BankAccountsTab> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BankAccountProvider>();
      provider.loadBankAccounts().then((_) {
        setState(() => _initialized = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bankProvider = context.watch<BankAccountProvider>();
    final isLoading = bankProvider.isLoading;
    final error = bankProvider.errorMessage;
    final accounts = bankProvider.bankAccounts;

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
              child: RefreshIndicator(
                onRefresh: () => bankProvider.loadBankAccounts(),
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final BankAccount acct = accounts[index];
                    return ListTile(
                      title: Text(acct.accountName),
                      subtitle: Text('${acct.institutionName} • ${acct.balance} ${acct.currency}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await bankProvider.deleteBankAccount(acct.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final accountNameCtrl = TextEditingController();
        final accountNumberCtrl = TextEditingController();
        final institutionNameCtrl = TextEditingController();
        final balanceCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Add Account'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: accountNameCtrl, decoration: const InputDecoration(labelText: 'Account Name')),
                TextField(controller: accountNumberCtrl, decoration: const InputDecoration(labelText: 'Account Number')),
                TextField(controller: institutionNameCtrl, decoration: const InputDecoration(labelText: 'Institution Name')),
                TextField(controller: balanceCtrl, decoration: const InputDecoration(labelText: 'Balance')),
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
                final bankProvider = context.read<BankAccountProvider>();
                await bankProvider.createBankAccount(
                  accountName: accountNameCtrl.text,
                  accountNumber: accountNumberCtrl.text,
                  institutionName: institutionNameCtrl.text,
                  balance: double.tryParse(balanceCtrl.text) ?? 0.0,
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