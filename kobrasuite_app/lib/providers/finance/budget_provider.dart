import 'package:flutter/foundation.dart';
import '../../../services/finance/banking_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/budget.dart';

class BudgetProvider extends ChangeNotifier {
  final BankingService _service;
  int _userPk;
  int _financeProfilePk;

  bool _isLoading = false;
  String _errorMessage = '';
  List<Budget> _budgets = [];

  BudgetProvider({
    required int userPk,
    required int financeProfilePk,
  })  : _userPk = userPk,
        _financeProfilePk = financeProfilePk,
        _service = serviceLocator<BankingService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Budget> get budgets => _budgets;

  int get userPk => _userPk;
  int get financeProfilePk => _financeProfilePk;

  void update({
    required int newUserPk,
    required int newFinanceProfilePk,
  }) {
    _userPk = newUserPk;
    _financeProfilePk = newFinanceProfilePk;
    notifyListeners();
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final list = await _service.getBudgets(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
      );
      _budgets = list;
    } catch (e) {
      _errorMessage = 'Error loading budgets: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

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
      final success = await _service.createBudget(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
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

  Future<bool> deleteBudget(int budgetId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.deleteBudget(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
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