import 'package:flutter/foundation.dart';
import '../../../services/finance/banking_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/budget.dart';
import '../general/finance_profile_provider.dart';

class BudgetProvider extends ChangeNotifier {
  final BankingService _budgetService;
  FinanceProfileProvider _financeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<Budget> _budgets = [];

  BudgetProvider({required FinanceProfileProvider financeProfileProvider,})
      : _financeProfileProvider = financeProfileProvider,
        _budgetService = serviceLocator<BankingService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Budget> get budgets => _budgets;

  /// Convenience getters
  int get userPk => _financeProfileProvider.userPk;
  int get userProfilePk => _financeProfileProvider.userProfilePk;
  int get financeProfilePk => _financeProfileProvider.financeProfilePk;

  /// Allow updating the linked FinanceProfileProvider
  void update(FinanceProfileProvider newFinanceProfileProvider) {
    _financeProfileProvider = newFinanceProfileProvider;
    notifyListeners();
  }

  Budget? byId(int id) {
    try {
      return _budgets.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Load all budgets for the current FinanceProfile
  Future<void> loadBudgets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _budgetService.getBudgets(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
      );
      _budgets = list;
    } catch (e) {
      _errorMessage = 'Error loading budgets: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create a new budget and reload the list if successful
  Future<bool> createBudget({
    required String name,
    required double totalAmount,
    required String startDate,
    required String endDate,
    bool isActive = true,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final success = await _budgetService.createBudget(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
        name: name,
        totalAmount: totalAmount,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
      );
      if (success) {
        await loadBudgets();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating budget: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a budget by ID and update the list
  Future<bool> deleteBudget(int budgetId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final success = await _budgetService.deleteBudget(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
        budgetId: budgetId,
      );
      if (success) {
        _budgets.removeWhere((b) => b.id == budgetId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting budget: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}