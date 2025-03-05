// lib/modules/finances/tabs/bank_accounts_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/models/finance/bank_account.dart';
import 'package:kobrasuite_app/providers/finance/bank_account_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';

import '../../../../nav/providers/control_bar_registrar.dart';


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
    // Load data after the widget builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankAccountProvider>().loadBankAccounts().then((_) {
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

    // Use ControlBarRegistrar with financeTabIndex = 0 (for Accounts)
    return ControlBarRegistrar(
      financeTabIndex: 0,
      buttons: [
        ControlBarButtonModel(
          icon: Icons.add,
          label: 'Add Account',
          onPressed: _showAddAccountDialog,
        ),
      ],
      child: Scaffold(
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
                child: RefreshIndicator(
                  onRefresh: bankProvider.loadBankAccounts,
                  child: ListView.separated(
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final BankAccount account = accounts[index];
                      return ListTile(
                        title: Text(account.accountName),
                        subtitle: Text(
                          '${account.institutionName} • ${account.balance} ${account.currency}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => bankProvider.deleteBankAccount(account.id),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddBankAccountDialog(),
    );
  }
}

class _AddBankAccountDialog extends StatefulWidget {
  const _AddBankAccountDialog({Key? key}) : super(key: key);

  @override
  State<_AddBankAccountDialog> createState() => _AddBankAccountDialogState();
}

class _AddBankAccountDialogState extends State<_AddBankAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _institutionNameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();

  @override
  void dispose() {
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _institutionNameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final bankProvider = context.read<BankAccountProvider>();
      final success = await bankProvider.createBankAccount(
        accountName: _accountNameCtrl.text,
        accountNumber: _accountNumberCtrl.text,
        institutionName: _institutionNameCtrl.text,
        balance: double.parse(_balanceCtrl.text),
      );
      if (success && mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Bank Account'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountNameCtrl,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter account name' : null,
              ),
              TextFormField(
                controller: _accountNumberCtrl,
                decoration: const InputDecoration(labelText: 'Account Number'),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter account number' : null,
              ),
              TextFormField(
                controller: _institutionNameCtrl,
                decoration: const InputDecoration(labelText: 'Institution Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter institution name' : null,
              ),
              TextFormField(
                controller: _balanceCtrl,
                decoration: const InputDecoration(labelText: 'Balance'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter balance';
                  if (double.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveAccount, child: const Text('Save')),
      ],
    );
  }
}