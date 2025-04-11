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
  final TextEditingController _searchController = TextEditingController();
  final List<BankAccount> _filteredAccounts = [];
  bool _isSearching = false;
  Timer? _debounce;
  CancelableOperation<void>? _searchOperation;

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
    _searchController.dispose();
    _debounce?.cancel();
    _searchOperation?.cancel();
    super.dispose();
  }

  /// Called whenever the text in the search field changes.
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      final provider = Provider.of<BankAccountProvider>(context, listen: false);
      _filteredAccounts
        ..clear()
        ..addAll(provider.bankAccounts);
      setState(() {});
      return;
    }
    // Debounce user input for smoother searching
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchOperation?.cancel();
      _searchOperation = CancelableOperation.fromFuture(_filterAccounts(query));
    });
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
    // Re-apply filtering if the user typed something
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _filteredAccounts
        ..clear()
        ..addAll(provider.bankAccounts);
    } else {
      await _filterAccounts(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bankProvider = context.watch<BankAccountProvider>();
    final accounts = bankProvider.bankAccounts;
    final isLoading = bankProvider.isLoading;
    final errorMessage = bankProvider.errorMessage ?? '';

    // Calculate total balance
    final totalBalance = accounts.fold<double>(
      0.0,
          (prev, account) => prev + (account.balance ?? 0.0),
    );

    return Scaffold(
      body: Column(
        children: [
          // Top row with search bar or icon
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search accounts by name, institution, or last 4',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        _filteredAccounts
                          ..clear()
                          ..addAll(bankProvider.bankAccounts);
                      });
                    },
                  ),
                ],
              ),
            )
          else
          // If not searching, show a search button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                ],
              ),
            ),

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