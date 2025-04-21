import 'package:dio/dio.dart';
import '../../models/finance/portfolio_stock.dart';
import '../../models/finance/stock_portfolio.dart';
import '../../services/service_locator.dart';

class StockPortfolioService {
  final Dio _dio;

  StockPortfolioService(this._dio);

  /* ------------------------------------------------------------------ */
  Future<bool> createStockPortfolio({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final uri =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/';
    try {
      final r = await _dio.post(uri);
      return r.statusCode == 200 || r.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /* ------------------------------------------------------------------ */
  Future<StockPortfolio?> getStockPortfolio({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/'; // pk == fp id
    try {
      final r = await _dio.get(p);
      if (r.statusCode == 200) {
        return StockPortfolio.fromJson(r.data);
      }
    } catch (_) {}
    return null;
  }

  /* ------------------------------------------------------------------ */
  Future<List<PortfolioStock>> getPortfolioStocks({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/stocks/';
    try {
      final r = await _dio.get(p);
      if (r.statusCode == 200) {
        return (r.data as List)
            .map((e) => PortfolioStock.fromJson(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /* ------------------------------------------------------------------ */
  Future<bool> addStock({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required String ticker,
    required double numShares,
    String? purchaseDateIso,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/add_stock/';

    final body = {
      'ticker': ticker,
      'num_shares': numShares,
      if (purchaseDateIso != null) 'purchase_date': purchaseDateIso,
    };

    try {
      final r = await _dio.post(p, data: body);
      return r.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /* ------------------------------------------------------------------ */
  Future<bool> removeStock({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required String ticker,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/remove_stock/$ticker';
    try {
      final r = await _dio.delete(p);
      return r.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /* ---------------- analytics & extras ----------------------------- */
  Future<Map<String, double>> getPortfolioMetrics({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/analysis/';
    try {
      final r = await _dio.get(p);
      if (r.statusCode == 200) {
        final m = r.data['metrics'] as Map<String, dynamic>;
        return m.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (_) {}
    return {};
  }

  Future<List<String>> getPortfolioChat({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/analysis/';
    try {
      final r = await _dio.get(p);
      if (r.statusCode == 200) {
        final list = r.data['chat_responses'] as List?;
        return list?.cast<String>() ?? [];
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getPortfolioValueSeries({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  }) async {
    final p =
        '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
        '$financeProfilePk/stock_portfolio/$financeProfilePk/value_series/';
    try {
      final r = await _dio.get(p);
      if (r.statusCode == 200) {
        return (r.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  /* ---------------- single‑stock analysis -------------------------- */
  Future<String> getStockAnalysis(String ticker) async {
    try {
      final r = await _dio
          .get('/api/misc_invest/stock_analysis/', queryParameters: {'ticker': ticker});
      if (r.statusCode == 200) return r.data['analysis'] ?? '';
    } catch (_) {}
    return '';
  }
}