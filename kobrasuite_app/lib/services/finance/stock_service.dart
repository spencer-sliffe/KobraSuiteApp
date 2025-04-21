import 'package:dio/dio.dart';
import '../../models/finance/watchlist_stock.dart';
import '../../services/service_locator.dart';

class StockService {
  final Dio _dio;

  StockService(this._dio);

  /* ------------------------------------------------------------------ */
  Future<List<WatchlistStock>> getWatchlistStocks({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/watchlist_stocks/';
    try {
      final r = await _dio.get(p);
      if (r.statusCode == 200) {
        return (r.data as List)
            .map((e) => WatchlistStock.fromJson(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /* ------------------------------------------------------------------ */
  Future<bool> addWatchlistStock({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required String ticker,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/watchlist_stocks/';
    try {
      final r = await _dio.post(p, data: {'ticker': ticker});
      return r.statusCode == 200 || r.statusCode == 201;
    } catch (_) {}
    return false;
  }

  /* ------------------------------------------------------------------ */
  Future<bool> removeWatchlistStock({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required int watchlistStockId,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/watchlist_stocks/'
        '$watchlistStockId';
    try {
      final r = await _dio.delete(p);
      return r.statusCode == 200;
    } catch (_) {}
    return false;
  }
}