import 'package:dio/dio.dart';
import '../../../models/finance/stock_portfolio.dart';
import '../../../models/finance/portfolio_stock.dart';
import '../../models/finance/watchlist_stock.dart';

class StockService {
  final Dio _dio;

  StockService(this._dio);

  Future<StockPortfolio?> getStockPortfolio({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        return StockPortfolio.fromJson(response.data);
      }
    } catch (_) {}
    return null;
  }

  Future<List<PortfolioStock>> getPortfolioStocks({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/stocks/';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => PortfolioStock.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> addStock({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
    required String ticker,
    required double numShares,
    String? purchaseDateIso,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/add_stock/';
    final body = {
      'ticker': ticker,
      'num_shares': numShares,
    };
    if (purchaseDateIso != null) {
      body['purchase_date'] = purchaseDateIso;
    }
    try {
      final response = await _dio.post(path, data: body);
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> removeStock({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
    required String ticker,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/remove_stock/$ticker';
    try {
      final response = await _dio.delete(path);
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> removeWatchlistStock({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
    required int watchlistStockId,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/watchlist_stocks/$watchlistStockId';
    try {
      final response = await _dio.delete(path);
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>?> getPortfolioAnalysis({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/analysis/';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (_) {}
    return null;
  }

  Future<List<WatchlistStock>> getWatchlistStocks({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/watchlist_stocks/';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => WatchlistStock.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> addWatchlistStock({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
    required String ticker,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/stock_portfolio/$stockPortfolioPk/watchlist_stocks/';
    try {
      final response = await _dio.post(path, data: {'ticker': ticker});
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {}
    return false;
  }
}