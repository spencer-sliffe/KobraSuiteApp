// lib/UI/screens/modules/finances/tabs/bank_accounts_tab.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../models/detail_target.dart';
import '../../../../../providers/finance/bank_account_provider.dart';
import '../../../../nav/providers/navigation_store.dart';
import '../../../../../models/model_kind_enum.dart';
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
          _buildSearchField(),
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
                  : _buildAccountsList(
                  context, totalBalance, accountsToDisplay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search accounts',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () {
            _filterAccounts(value);
          });
        },
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
            onTap: () {
              context.read<NavigationStore>().showDetail(
                DetailTarget(kind: ModelKind.bankAccount, id: acct.id),
              );
            },
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
