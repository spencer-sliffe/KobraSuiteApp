import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../models/finance/bank_account.dart';
import '../../../../../providers/finance/bank_account_provider.dart';
import '../../../../widgets/cards/finance/bank_account_card.dart';

class BankAccountsTab extends StatefulWidget {
  const BankAccountsTab({Key? key}) : super(key: key);

  @override
  State<BankAccountsTab> createState() => _BankAccountsTabState();
}

class _BankAccountsTabState extends State<BankAccountsTab> {
  final List<BankAccount> _filteredAccounts = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BankAccountProvider>(context, listen: false);
    // Load accounts on init
    provider.loadBankAccounts().then((_) {
      if (!mounted) return;
      setState(() {
        _filteredAccounts.clear();
        _filteredAccounts.addAll(provider.bankAccounts);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Filter the loaded accounts by the given query
  Future<void> _filterAccounts(String query) async {
    final provider = Provider.of<BankAccountProvider>(context, listen: false);
    final lowerQuery = query.toLowerCase();

    final result = provider.bankAccounts.where((acct) {
      final name = acct.accountName.toLowerCase();
      final institution = acct.institutionName.toLowerCase();
      final last4 = acct.accountNumber.toLowerCase();
      return name.contains(lowerQuery) ||
          institution.contains(lowerQuery) ||
          last4.contains(lowerQuery);
    }).toList();

    if (!mounted) return;
    setState(() {
      _filteredAccounts
        ..clear()
        ..addAll(result);
    });
  }

  /// Pull-to-refresh callback
  Future<void> _onRefresh() async {
    final provider = Provider.of<BankAccountProvider>(context, listen: false);
    await provider.loadBankAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final bankProvider = context.watch<BankAccountProvider>();
    final accounts = bankProvider.bankAccounts;
    final isLoading = bankProvider.isLoading;
    final errorMessage = bankProvider.errorMessage ?? '';

    final totalBalance = accounts.fold<double>(
      0.0,
          (prev, account) => prev + (account.balance ?? 0.0),
    );

    return Scaffold(
      body: Column(
        children: [
          // If loading, show a loading indicator
          if (isLoading) const LinearProgressIndicator(),

          // Expanded list area
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: errorMessage.isNotEmpty
                  ? ListView(
                // If there's an error, show it
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Error: $errorMessage',
                      style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
              )
                  : _buildAccountsList(context, totalBalance),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList(BuildContext context, double totalBalance) {
    // If using local _filteredAccounts, show that; if empty, show fallback
    final accounts = _filteredAccounts;
    if (accounts.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No bank accounts found.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      );
    }

    return ListView(
      children: [
        // Some summary up top
        _buildOverviewCard('Total Balance: \$${totalBalance.toStringAsFixed(2)}',
            'Sum of all bank account balances.'),
        _buildOverviewCard('Number of Accounts: ${accounts.length}',
            'Overview of your linked bank accounts.'),
        const SizedBox(height: 12),
        // Then list all accounts
        ...accounts.map(
              (acct) => BankAccountCard(
            account: acct,
            onDelete: () {
              // Example usage: you can call a confirm dialog, then bankProvider.deleteBankAccount(acct.id!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String subtitle) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}