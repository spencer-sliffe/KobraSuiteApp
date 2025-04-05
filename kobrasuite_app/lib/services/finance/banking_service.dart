import 'package:dio/dio.dart';
import '../../models/finance/bank_account.dart';
import '../../models/finance/budget.dart';
import '../../models/finance/budget_category.dart';
import '../../models/finance/transaction.dart';

class BankingService {
  final Dio _dio;

  BankingService(this._dio);

  // Bank Accounts
  Future<List<BankAccount>> getBankAccounts({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/bank_accounts/';
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      final map = response.data as Map<String, dynamic>;
      final results = map['results'] as List;
      return results.map((e) => BankAccount.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createBankAccount({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required String accountName,
    required String accountNumber,
    required String institutionName,
    required double balance,
    String currency = 'USD',
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/'
        'finance_profile/$financeProfilePk/bank_accounts/';
    final body = {
      'account_name': accountName,
      'account_number': accountNumber,
      'institution_name': institutionName,
      'balance': balance,
      'currency': currency,
    };
    final response = await _dio.post(url, data: body);
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> deleteBankAccount({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required int bankAccountId,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/'
        'finance_profile/$financeProfilePk/bank_accounts/$bankAccountId/';
    final response = await _dio.delete(url);
    return response.statusCode == 204 || response.statusCode == 200;
  }

  // Budgets
  Future<List<Budget>> getBudgets({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final url = '/api/users/$userPk/profile/$userProfilePk/'
        'finance_profile/$financeProfilePk/budgets/';
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      final map = response.data as Map<String, dynamic>;
      final results = map['results'] as List;
      return results.map((e) => Budget.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createBudget({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required String name,
    required double totalAmount,
    required String startDate,
    required String endDate,
    bool isActive = true,
  }) async {
    final url = '/api/users/$userPk/profile/$userProfilePk'
        '/finance_profile/$financeProfilePk/budgets/';
    final body = {
      'name': name,
      'total_amount': totalAmount,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
    };
    final response = await _dio.post(url, data: body);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteBudget({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required int budgetId,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk'
        '/finance_profile/$financeProfilePk/budgets/$budgetId/';
    final response = await _dio.delete(url);
    return response.statusCode == 204 || response.statusCode == 200;
  }

  // Budget Categories
  Future<List<BudgetCategory>> getBudgetCategories({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/'
        'finance_profile/$financeProfilePk/budget_categories/';
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      final map = response.data as Map<String, dynamic>;
      final results = map['results'] as List;
      return results.map((e) => BudgetCategory.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createBudgetCategory({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required int budgetId,
    required String name,
    required double allocatedAmount,
    required String categoryType,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/'
        'finance_profile/$financeProfilePk/budget_categories/';
    final body = {
      'budget': budgetId,
      'name': name,
      'allocated_amount': allocatedAmount,
      'category_type': categoryType,
    };
    final response = await _dio.post(url, data: body);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteBudgetCategory({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required int categoryId,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/'
        'finance_profile/$financeProfilePk/budget_categories/$categoryId/';
    final response = await _dio.delete(url);
    return response.statusCode == 204 || response.statusCode == 200;
  }

  // Transactions
  Future<List<Transaction>> getTransactions({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/'
        'finance_profile/$financeProfilePk/transactions/';
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      final map = response.data as Map<String, dynamic>;
      final results = map['results'] as List;
      return results.map((e) => Transaction.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createTransaction({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required String transactionType,
    required double amount,
    int? bankAccountId,
    int? budgetCategoryId,
    String? description,
    String? dateIso,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/$financeProfilePk/transactions/';
    final body = {
      'transaction_type': transactionType,
      'amount': amount,
      if (bankAccountId != null) 'bank_account': bankAccountId,
      if (budgetCategoryId != null) 'budget_category': budgetCategoryId,
      if (description != null) 'description': description,
      if (dateIso != null) 'date': dateIso,
    };
    final response = await _dio.post(url, data: body);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteTransaction({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required int transactionId,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/'
        'finance_profile/$financeProfilePk/transactions/$transactionId/';
    final response = await _dio.delete(url);
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
