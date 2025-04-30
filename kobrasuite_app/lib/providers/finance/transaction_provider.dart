// lib/providers/finance/transaction_provider.dart
import 'package:flutter/foundation.dart';
import '../../../services/finance/banking_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/transaction.dart';
import '../general/finance_profile_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final BankingService _service;
  FinanceProfileProvider _financeProfileProvider;

  bool _isLoading = false;
  String _errorMessage = '';
  List<Transaction> _transactions = [];

  TransactionProvider({required FinanceProfileProvider financeProfileProvider})
      : _financeProfileProvider = financeProfileProvider,
        _service = serviceLocator<BankingService>();

  /* ─── getters ───────────────────────────────────────────────── */
  bool   get isLoading       => _isLoading;
  String get errorMessage    => _errorMessage;
  List<Transaction> get transactions => _transactions;

  int get userPk            => _financeProfileProvider.userPk;
  int get userProfilePk     => _financeProfileProvider.userProfilePk;
  int get financeProfilePk  => _financeProfileProvider.financeProfilePk;

  /* ─── syncing with FinanceProfileProvider ───────────────────── */
  void update(FinanceProfileProvider newFinanceProfileProvider) {
    final bool changed = newFinanceProfileProvider.financeProfilePk != financeProfilePk;
    _financeProfileProvider = newFinanceProfileProvider;
    notifyListeners();
    if (changed) loadTransactions();
  }

  /* ─── read all ──────────────────────────────────────────────── */
  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _transactions = await _service.getTransactions(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
      );
    } catch (e) {
      _errorMessage = 'Error loading transactions: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /* ─── create ────────────────────────────────────────────────── */
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
      final ok = await _service.createTransaction(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
        transactionType: transactionType,
        amount: amount,
        bankAccountId: bankAccountId,
        budgetCategoryId: budgetCategoryId,
        description: description,
        dateIso: dateIso,
      );
      if (ok) await loadTransactions();
      return ok;
    } catch (e) {
      _errorMessage = 'Error creating transaction: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* ─── delete ────────────────────────────────────────────────── */
  Future<bool> deleteTransaction(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final ok = await _service.deleteTransaction(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
        transactionId: id,
      );
      if (ok) _transactions.removeWhere((t) => t.id == id);
      return ok;
    } catch (e) {
      _errorMessage = 'Error deleting transaction: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}