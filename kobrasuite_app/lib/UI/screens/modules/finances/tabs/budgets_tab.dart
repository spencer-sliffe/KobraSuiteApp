import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/finance/budget_provider.dart';
import '../../../../widgets/cards/finance/budget_card.dart';

class BudgetsTab extends StatefulWidget {
  const BudgetsTab({Key? key}) : super(key: key);

  @override
  State<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends State<BudgetsTab> {
  // Local list used for filtering.
  List _filteredBudgets = [];
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Optionally initialize the filtered list with the current provider value.
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    _filteredBudgets = List.from(provider.budgets);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Pull-to-refresh callback (if you want to manually refresh in this view).
  Future<void> _onRefresh() async {
    // Optionally, you can trigger a refresh in the provider.
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    await provider.loadBudgets();
  }

  /// Filter budgets based on the entered query.
  Future<void> _filterBudgets(String query) async {
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final lowerQuery = query.toLowerCase();

    final results = provider.budgets.where((budget) {
      return budget.name.toLowerCase().contains(lowerQuery);
    }).toList();

    if (!mounted) return;
    setState(() {
      _searchQuery = query;
      _filteredBudgets = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final isLoading = budgetProvider.isLoading;
    final errorMessage = budgetProvider.errorMessage ?? '';
    // Use either the filtered list if there's a search query, or all budgets.
    final budgetsToDisplay =
    _searchQuery.isEmpty ? budgetProvider.budgets : _filteredBudgets;

    final totalBudgetAmount = budgetProvider.budgets.fold<double>(
      0.0,
          (prev, budget) => prev + budget.totalAmount,
    );

    return Scaffold(
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          // Simple summary header.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Budget: \$${totalBudgetAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
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
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              )
                  : _buildBudgetsList(budgetsToDisplay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsList(List budgets) {
    if (budgets.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 16),
          Center(child: Text('No budgets found.')),
        ],
      );
    }

    return ListView(
      children: budgets
          .map((budget) => BudgetCard(
        budget: budget,
        onDelete: () {
          // Optionally, implement deletion via the provider.
        },
      ))
          .toList(),
    );
  }
}