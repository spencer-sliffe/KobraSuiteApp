import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/finance/bank_account_provider.dart';
import '../../../../widgets/cards/finance/bank_account_card.dart';

class BankAccountsTab extends StatefulWidget {
  const BankAccountsTab({Key? key}) : super(key: key);

  @override
  State<BankAccountsTab> createState() => _BankAccountsTabState();
}

class _BankAccountsTabState extends State<BankAccountsTab> {
  // Local list used for filtering.
  final List _filteredAccounts = [];
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize local filtered list from the provider's existing data.
    final provider = Provider.of<BankAccountProvider>(context, listen: false);
    _filteredAccounts.addAll(provider.bankAccounts);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Filter accounts based on the given query.
  Future<void> _filterAccounts(String query) async {
    final provider = Provider.of<BankAccountProvider>(context, listen: false);
    final lowerQuery = query.toLowerCase();

    final results = provider.bankAccounts.where((acct) {
      final name = acct.accountName.toLowerCase();
      final institution = acct.institutionName.toLowerCase();
      final last4 = acct.accountNumber.toLowerCase();
      return name.contains(lowerQuery) ||
          institution.contains(lowerQuery) ||
          last4.contains(lowerQuery);
    }).toList();

    if (!mounted) return;
    setState(() {
      _searchQuery = query;
      _filteredAccounts
        ..clear()
        ..addAll(results);
    });
  }

  /// Pull-to-refresh callback.
  Future<void> _onRefresh() async {
    final provider = Provider.of<BankAccountProvider>(context, listen: false);
    await provider.loadBankAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final bankProvider = context.watch<BankAccountProvider>();
    final isLoading = bankProvider.isLoading;
    final errorMessage = bankProvider.errorMessage ?? '';
    // Use either the filtered accounts or all accounts.
    final accountsToDisplay =
    _searchQuery.isEmpty ? bankProvider.bankAccounts : _filteredAccounts;

    final totalBalance = bankProvider.bankAccounts.fold<double>(
      0.0,
          (prev, account) => prev + (account.balance ?? 0.0),
    );

    return Scaffold(
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: errorMessage.isNotEmpty
                  ? ListView(
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Error: $errorMessage',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
              )
                  : _buildAccountsList(context, totalBalance, accountsToDisplay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList(
      BuildContext context, double totalBalance, List accounts) {
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
        // Overview cards for bank account summaries.
        _buildOverviewCard(
          'Total Balance: \$${totalBalance.toStringAsFixed(2)}',
          'Sum of all bank account balances.',
        ),
        _buildOverviewCard(
          'Number of Accounts: ${accounts.length}',
          'Overview of your linked bank accounts.',
        ),
        const SizedBox(height: 12),
        // List of bank account cards.
        ...accounts.map(
              (acct) => BankAccountCard(
            account: acct,
            onDelete: () {
              // Optionally implement deletion functionality.
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}