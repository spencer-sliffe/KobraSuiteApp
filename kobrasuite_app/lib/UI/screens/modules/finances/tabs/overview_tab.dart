// lib/modules/finances/tabs/overview_tab.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../models/finance/bank_account.dart';
import '../../../../../models/finance/budget.dart';
import '../../../../../providers/finance/bank_account_provider.dart';
import '../../../../../providers/finance/budget_provider.dart';


class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  // Local lists to hold fetched budgets and accounts—allowing filtering or local state handling.
  final List<Budget> _budgetsFiltered = [];
  final List<BankAccount> _filteredAccounts = [];

  // Optionally, you can have a local "loading" flag if you want to display a loader.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Get the providers without listening for changes immediately.
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final bankAccountProvider = Provider.of<BankAccountProvider>(context, listen: false);

    // Set loading flag and load both budgets and bank accounts concurrently.
    setState(() {
      _isLoading = true;
    });

    Future.wait([
      budgetProvider.loadBudgets(),
      bankAccountProvider.loadBankAccounts(),
    ]).then((_) {
      // Once both async operations are complete, update the local lists.
      if (!mounted) return;
      setState(() {
        _budgetsFiltered
          ..clear()
          ..addAll(budgetProvider.budgets);
        _filteredAccounts
          ..clear()
          ..addAll(bankAccountProvider.bankAccounts);
        _isLoading = false;
      });
    }).catchError((error) {
      // Handle error if needed.
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total bank balance from the loaded bank accounts.
    final totalBankBalance = _filteredAccounts.fold<double>(
      0.0,
          (prev, account) => prev + (account.balance ?? 0.0),
    );

    // Calculate total budget amount from the loaded budgets.
    final totalBudgetAmount = _budgetsFiltered.fold<double>(
      0.0,
          (prev, budget) => prev + budget.totalAmount,
    );

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card for total bank account balance.
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
                color: Colors.green,
              ),
              title: const Text('Total Bank Balance'),
              subtitle: Text('\$${totalBankBalance.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 12),

          // Card for the number of bank accounts.
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              leading: const Icon(
                Icons.account_balance,
                color: Colors.blue,
              ),
              title: const Text('Number of Bank Accounts'),
              subtitle: Text('${_filteredAccounts.length}'),
            ),
          ),
          const SizedBox(height: 12),

          // Card for total budget amount.
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              leading: const Icon(
                Icons.bar_chart,
                color: Colors.orange,
              ),
              title: const Text('Total Budget Amount'),
              subtitle:
              Text('\$${totalBudgetAmount.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 12),

          // Optional extra insights.
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              leading: const Icon(
                Icons.trending_up,
                color: Colors.purple,
              ),
              title: const Text('Additional Trends'),
              subtitle: const Text(
                  'Placeholder for financial trends and charts'),
            ),
          ),
        ],
      ),
    );
  }
}