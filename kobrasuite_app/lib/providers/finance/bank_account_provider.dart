import 'package:flutter/foundation.dart';
import '../../../services/finance/banking_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/bank_account.dart';
import '../general/finance_profile_provider.dart'; // Adjust the path based on your project structure

class BankAccountProvider extends ChangeNotifier {
  final BankingService _bankingService;
  FinanceProfileProvider _financeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<BankAccount> _bankAccounts = [];

  BankAccountProvider({required FinanceProfileProvider financeProfileProvider})
      : _financeProfileProvider = financeProfileProvider,
        _bankingService = serviceLocator<BankingService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BankAccount> get bankAccounts => _bankAccounts;

  int get userPk => _financeProfileProvider.userPk;
  int get userProfilePk => _financeProfileProvider.userProfilePk;
  int get financeProfilePk => _financeProfileProvider.financeProfilePk;

  /// Updates the provider with a new FinanceProfileProvider.
  void update(FinanceProfileProvider newFinanceProfileProvider) {
    _financeProfileProvider = newFinanceProfileProvider;
    notifyListeners();
  }

  /// Loads bank accounts using the current profile IDs.
  Future<void> loadBankAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final accounts = await _bankingService.getBankAccounts(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
      );
      _bankAccounts = accounts;
    } catch (e) {
      _errorMessage = 'Error loading bank accounts: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Creates a new bank account and reloads the accounts list upon success.
  Future<bool> createBankAccount({
    required String accountName,
    required String accountNumber,
    required String institutionName,
    required double balance,
    String currency = 'USD',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _bankingService.createBankAccount(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
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

  /// Deletes the bank account with the specified [bankAccountId] and updates the accounts list.
  Future<bool> deleteBankAccount(int bankAccountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _bankingService.deleteBankAccount(
        userPk: userPk,
        userProfilePk: userProfilePk,
        financeProfilePk: financeProfilePk,
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