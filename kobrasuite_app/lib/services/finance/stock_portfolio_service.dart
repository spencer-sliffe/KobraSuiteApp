import 'package:dio/dio.dart';
import '../../models/finance/stock_portfolio.dart';

class StockPortfolioService {
  final Dio _dio;
  StockPortfolioService(this._dio);

  Future<StockPortfolio?> fetchStockPortfolio({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
  }) async {
    final uri = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/';
    try {
      final response = await _dio.get(uri);
      if (response.statusCode == 200) {
        return StockPortfolio.fromJson(response.data);
      }
      return null;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> createStockPortfolioIfNone({
    required int userPk,
    required int financeProfilePk,
  }) async {
    final uri = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/';
    try {
      final response = await _dio.post(uri);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}