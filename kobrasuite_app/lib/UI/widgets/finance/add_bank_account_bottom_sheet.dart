import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Needed for FilteringTextInputFormatter
import 'package:provider/provider.dart';
import '../../../providers/finance/bank_account_provider.dart';
import '../../nav/providers/navigation_store.dart';

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

    final bankProvider = context.read<BankAccountProvider>();
    final success = await bankProvider.createBankAccount(
      accountName: _accountNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      institutionName: _institutionNameController.text.trim(),
      balance: double.tryParse(
        _balanceController.text.replaceAll('\$', '').trim(),
      ) ?? 0.0,
      currency: _currency,
    );

    if (success) {
      setState(() => _state = AddBankAccountState.added);
    } else {
      setState(() {
        _errorFeedback = ((bankProvider.errorMessage ?? '').isNotEmpty)
            ? bankProvider.errorMessage!
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

    // Normal form
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
              (value == null || value.trim().isEmpty)
                  ? 'Enter account name'
                  : null,
            ),
            const SizedBox(height: 12),

            // Last 4 of Account Number
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Account Number (Last 4)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the last 4 digits';
                }
                if (value.trim().length < 4) {
                  return 'Must be exactly 4 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Institution Name
            TextFormField(
              controller: _institutionNameController,
              decoration:
              const InputDecoration(labelText: 'Institution Name'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter institution name'
                  : null,
            ),
            const SizedBox(height: 12),

            // Balance: numeric field with currency prefix & input formatter
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Balance',
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter balance';
                }
                final rawNumber = value.replaceAll('\$', '').trim();
                if (double.tryParse(rawNumber) == null) {
                  return 'Enter a valid number';
                }
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
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _currency = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            if (_errorFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorFeedback,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red),
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
        ),
      ];
    }
    if (_state == AddBankAccountState.initial) {
      return [
        TextButton(
          onPressed: () =>
              context.read<NavigationStore>().setAddBankAccountActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addBankAccount,
          child: const Text('Add Account'),
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
            ),
          ],
        ),
      ),
    );
  }
}