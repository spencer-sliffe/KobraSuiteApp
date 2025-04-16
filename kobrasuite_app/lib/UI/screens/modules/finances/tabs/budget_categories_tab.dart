// lib/modules/finances/tabs/budget_categories_tab.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../models/finance/budget_category.dart';
import '../../../../../providers/finance/budget_category_provider.dart';
import '../../../../../providers/finance/budget_provider.dart';
import '../../../../widgets/cards/finance/budget_category_card.dart';

class BudgetCategoriesTab extends StatefulWidget {
  const BudgetCategoriesTab({Key? key}) : super(key: key);

  @override
  State<BudgetCategoriesTab> createState() => _BudgetCategoriesTabState();
}

class _BudgetCategoriesTabState extends State<BudgetCategoriesTab> {
  @override
  void initState() {
    super.initState();
    // Load budgets and then load categories for all budgets.
    Future.microtask(() async {
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      await budgetProvider.loadBudgets();
      final List<int> budgetIds = budgetProvider.budgets.map((b) => b.id).toList();

      final categoryProvider =
      Provider.of<BudgetCategoryProvider>(context, listen: false);
      await categoryProvider.loadCategoriesForAllBudgets(budgetIds: budgetIds);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Refresh callback to reload budgets and all categories.
  Future<void> _onRefresh() async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    await budgetProvider.loadBudgets();
    final List<int> budgetIds = budgetProvider.budgets.map((b) => b.id).toList();

    final categoryProvider =
    Provider.of<BudgetCategoryProvider>(context, listen: false);
    await categoryProvider.loadCategoriesForAllBudgets(budgetIds: budgetIds);
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final categoryProvider = context.watch<BudgetCategoryProvider>();
    final isLoading = categoryProvider.isLoading || budgetProvider.isLoading;
    final errorMessage = categoryProvider.errorMessage.isNotEmpty
        ? categoryProvider.errorMessage
        : (budgetProvider.errorMessage ?? '');

    // Use the categoriesByBudget map directly from provider.
    final categoriesByBudget = categoryProvider.categoriesByBudget;

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
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              )
                  : _buildBudgetsList(budgetProvider.budgets, categoriesByBudget),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a list view where each budget's header is shown with its categories listed underneath.
  Widget _buildBudgetsList(List budgets, Map<int, List<BudgetCategory>> categoriesByBudget) {
    if (budgets.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 16),
          Center(child: Text('No budgets available.')),
        ],
      );
    }

    return ListView.builder(
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        // Retrieve the list directly from the map using budget.id as the key.
        final budgetCategories = categoriesByBudget[budget.id] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                budget.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // If there are no categories, display a placeholder;
            // otherwise, show the list of categories.
            if (budgetCategories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('No categories found for this budget.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgetCategories.length,
                itemBuilder: (context, catIndex) {
                  final category = budgetCategories[catIndex];
                  return BudgetCategoryCard(
                    category: category,
                    onDelete: () async {
                      final categoryProvider =
                      Provider.of<BudgetCategoryProvider>(context, listen: false);
                      final success = await categoryProvider.deleteCategory(budget.id, category.id);
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to delete category.'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            const Divider(),
          ],
        );
      },
    );
  }
}