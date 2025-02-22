import 'package:flutter/foundation.dart';
import '../../../services/finance/banking_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/bank_account.dart';

class BankAccountProvider extends ChangeNotifier {
  final BankingService _service;
  int _userPk;
  int _financeProfilePk;

  bool _isLoading = false;
  String _errorMessage = '';
  List<BankAccount> _bankAccounts = [];

  BankAccountProvider({
    required int userPk,
    required int financeProfilePk,
  })  : _userPk = userPk,
        _financeProfilePk = financeProfilePk,
        _service = serviceLocator<BankingService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<BankAccount> get bankAccounts => _bankAccounts;

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

  Future<void> loadBankAccounts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final accounts = await _service.getBankAccounts(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
      );
      _bankAccounts = accounts;
    } catch (e) {
      _errorMessage = 'Error loading bank accounts: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBankAccount({
    required String accountName,
    required String accountNumber,
    required String institutionName,
    required double balance,
    String currency = 'USD',
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.createBankAccount(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        accountName: accountName,
        accountNumber: accountNumber,
        institutionName: institutionName,
        balance: balance,
        currency: currency,
      );
      if (success) {
        await loadBankAccounts();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating bank account: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBankAccount(int bankAccountId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.deleteBankAccount(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        bankAccountId: bankAccountId,
      );
      if (success) {
        _bankAccounts.removeWhere((a) => a.id == bankAccountId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting bank account: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}