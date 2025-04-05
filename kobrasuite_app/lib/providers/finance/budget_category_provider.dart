import 'package:flutter/foundation.dart';
import '../../../services/finance/banking_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/budget_category.dart';

class BudgetCategoryProvider extends ChangeNotifier {
  final BankingService _service;
  int _userPk;
  int _userProfilePk;
  int _financeProfilePk;

  bool _isLoading = false;
  String _errorMessage = '';
  List<BudgetCategory> _categories = [];

  BudgetCategoryProvider({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  })  : _userPk = userPk,
        _userProfilePk = userProfilePk,
        _financeProfilePk = financeProfilePk,
        _service = serviceLocator<BankingService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<BudgetCategory> get categories => _categories;

  int get userPk => _userPk;
  int get userProfilePk => _userProfilePk;
  int get financeProfilePk => _financeProfilePk;

  void update({
    required int newUserPk,
    required int newUserProfilePk,
    required int newFinanceProfilePk,
  }) {
    _userPk = newUserPk;
    _userProfilePk = newUserProfilePk;
    _financeProfilePk = newFinanceProfilePk;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final list = await _service.getBudgetCategories(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
      );
      _categories = list;
    } catch (e) {
      _errorMessage = 'Error loading budget categories: $e';
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
      final success = await _service.createBudgetCategory(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
        budgetId: budgetId,
        name: name,
        allocatedAmount: allocatedAmount,
        categoryType: categoryType,
      );
      if (success) {
        await loadCategories();
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

  Future<bool> deleteCategory(int categoryId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.deleteBudgetCategory(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
        categoryId: categoryId,
      );
      if (success) {
        _categories.removeWhere((c) => c.id == categoryId);
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