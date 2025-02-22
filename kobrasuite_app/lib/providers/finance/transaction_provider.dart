import 'package:flutter/foundation.dart';
import '../../../services/finance/banking_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final BankingService _service;
  int _userPk;
  int _financeProfilePk;

  bool _isLoading = false;
  String _errorMessage = '';
  List<Transaction> _transactions = [];

  TransactionProvider({
    required int userPk,
    required int financeProfilePk,
  })  : _userPk = userPk,
        _financeProfilePk = financeProfilePk,
        _service = serviceLocator<BankingService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Transaction> get transactions => _transactions;

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

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final list = await _service.getTransactions(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
      );
      _transactions = list;
    } catch (e) {
      _errorMessage = 'Error loading transactions: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTransaction({
    required String transactionType,
    required double amount,
    int? bankAccountId,
    int? budgetCategoryId,
    String? description,
    String? dateIso,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.createTransaction(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        transactionType: transactionType,
        amount: amount,
        bankAccountId: bankAccountId,
        budgetCategoryId: budgetCategoryId,
        description: description,
        dateIso: dateIso,
      );
      if (success) {
        await loadTransactions();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating transaction: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTransaction(int transactionId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.deleteTransaction(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        transactionId: transactionId,
      );
      if (success) {
        _transactions.removeWhere((t) => t.id == transactionId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting transaction: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}