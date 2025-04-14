// lib/providers/finance/budget_category_provider.dart

import 'package:flutter/foundation.dart';
import '../../../services/finance/banking_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/budget_category.dart';
import '../general/finance_profile_provider.dart';

class BudgetCategoryProvider extends ChangeNotifier {
  final BankingService _budgetCategoryService;
  FinanceProfileProvider _financeProfileProvider;

  bool _isLoading = false;
  String _errorMessage = '';
  // Store categories grouped by budget id
  Map<int, List<BudgetCategory>> _categoriesByBudget = {};

  BudgetCategoryProvider({required FinanceProfileProvider financeProfileProvider})
      : _financeProfileProvider = financeProfileProvider,
        _budgetCategoryService = serviceLocator<BankingService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  // Expose the map of categories per budget id
  Map<int, List<BudgetCategory>> get categoriesByBudget => _categoriesByBudget;

  int get userPk => _financeProfileProvider.userPk;
  int get userProfilePk => _financeProfileProvider.userProfilePk;
  int get financeProfilePk => _financeProfileProvider.financeProfilePk;

  void update(FinanceProfileProvider newFinanceProfileProvider) {
    _financeProfileProvider = newFinanceProfileProvider;
    notifyListeners();
  }

  // Load categories for a single budget id, updating the map.
  Future<void> loadCategories({required int budgetId}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final list = await _budgetCategoryService.getBudgetCategories(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
        budgetId: budgetId,
      );
      _categoriesByBudget[budgetId] = list;
    } catch (e) {
      _errorMessage = 'Error loading budget categories for budget $budgetId: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load categories for all budgets by iterating through provided budget ids.
  Future<void> loadCategoriesForAllBudgets({required List<int> budgetIds}) async {
    _isLoading = true;
    _errorMessage = '';
    _categoriesByBudget.clear();
    notifyListeners();

    for (var budgetId in budgetIds) {
      try {
        final list = await _budgetCategoryService.getBudgetCategories(
          userPk: userPk,
          userProfilePk: userProfilePk,
          financeProfilePk: financeProfilePk,
          budgetId: budgetId,
        );
        _categoriesByBudget[budgetId] = list;
      } catch (e) {
        _errorMessage += 'Error loading categories for budget $budgetId: $e\n';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCategory({
    required int budgetId,
    required String name,
    required double allocatedAmount,
    required String categoryType,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _budgetCategoryService.createBudgetCategory(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
        budgetId: budgetId,
        name: name,
        allocatedAmount: allocatedAmount,
        categoryType: categoryType,
      );
      if (success) {
        await loadCategories(budgetId: budgetId);  // Reload the updated list for that budget
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating budget category: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(int budgetId, int categoryId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _budgetCategoryService.deleteBudgetCategory(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
        categoryId: categoryId,
      );
      if (success) {
        _categoriesByBudget[budgetId]?.removeWhere((c) => c.id == categoryId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting budget category: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}