import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/finance/bank_account_provider.dart';

enum AddBankAccountState { initial, adding, added }

class AddBankAccountBottomSheet extends StatefulWidget {
  const AddBankAccountBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddBankAccountBottomSheet> createState() =>
      _AddBankAccountBottomSheetState();
}

class _AddBankAccountBottomSheetState extends State<AddBankAccountBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _institutionNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String _currency = 'USD';

  AddBankAccountState _state = AddBankAccountState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _institutionNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _addBankAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _state = AddBankAccountState.adding;
      _errorFeedback = "";
    });
    // Access the BankAccountProvider from your widget tree.
    final bankProvider = context.read<BankAccountProvider>();
    final success = await bankProvider.createBankAccount(
      accountName: _accountNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      institutionName: _institutionNameController.text.trim(),
      balance: double.tryParse(_balanceController.text.trim()) ?? 0.0,
      currency: _currency,
    );
    if (success) {
      setState(() {
        _state = AddBankAccountState.added;
      });
    } else {
      setState(() {
        _errorFeedback = bankProvider.errorMessage.isNotEmpty
            ? bankProvider.errorMessage
            : 'Failed to add bank account.';
        _state = AddBankAccountState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddBankAccountState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding bank account...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddBankAccountState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Bank account added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }
    // Build the form
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
            // Account Name
            TextFormField(
              controller: _accountNameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter account name' : null,
            ),
            const SizedBox(height: 12),
            // Account Number
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(labelText: 'Account Number'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter account number' : null,
            ),
            const SizedBox(height: 12),
            // Institution Name
            TextFormField(
              controller: _institutionNameController,
              decoration: const InputDecoration(labelText: 'Institution Name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter institution name'
                  : null,
            ),
            const SizedBox(height: 12),
            // Balance: numeric field.
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(labelText: 'Balance'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter balance';
                if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Currency dropdown
            DropdownButtonFormField<String>(
              value: _currency,
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                // Add more currencies as needed.
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currency = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Currency'),
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
    if (_state == AddBankAccountState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        )
      ];
    }
    if (_state == AddBankAccountState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addBankAccount,
          child: const Text('Add Account'),
        )
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
            Text(
              'Add New Bank Account',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActions(),
            )
          ],
        ),
      ),
    );
  }
}