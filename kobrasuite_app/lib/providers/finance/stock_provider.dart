import 'package:flutter/foundation.dart';
import '../../../models/finance/watchlist_stock.dart';
import '../../../services/finance/stock_service.dart';
import '../../../services/service_locator.dart';
import '../general/finance_profile_provider.dart';
import 'stock_portfolio_provider.dart';

class StockProvider with ChangeNotifier {
  final StockService _svc = serviceLocator<StockService>();

  FinanceProfileProvider _fp;
  StockPortfolioProvider _pp;

  StockProvider({
    required FinanceProfileProvider financeProfileProvider,
    required StockPortfolioProvider portfolioProvider,
  })  : _fp = financeProfileProvider,
        _pp = portfolioProvider;

  /* ---------------- state ------------------- */
  bool _loading = false;
  String _error = '';
  List<WatchlistStock> _watchlist = [];

  bool get isLoading => _loading;
  String get errorMessage => _error;
  List<WatchlistStock> get watchlistStocks => _watchlist;

  /*  ids pulled from injected providers */
  int get _userPk => _fp.userPk;
  int get _userProfilePk => _fp.userProfilePk;
  int get _financeProfilePk => _fp.financeProfilePk;

  /* ---------------- updates ----------------- */
  void update({
    required FinanceProfileProvider newFinanceProfileProvider,
    required StockPortfolioProvider newPortfolioProvider,
  }) {
    _fp = newFinanceProfileProvider;
    _pp = newPortfolioProvider;
  }

  /* ---------------- CRUD -------------------- */
  Future<void> loadWatchlistStocks() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      _watchlist = await _svc.getWatchlistStocks(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
      );
    } catch (e) {
      _error = 'Error loading watchlist: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> addWatchlistStock(String ticker) async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      final ok = await _svc.addWatchlistStock(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
        ticker: ticker,
      );
      if (ok) await loadWatchlistStocks();
      return ok;
    } catch (e) {
      _error = 'Error adding stock: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> removeWatchlistStock(int id) async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      final ok = await _svc.removeWatchlistStock(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
        watchlistStockId: id,
      );
      if (ok) _watchlist.removeWhere((w) => w.id == id);
      return ok;
    } catch (e) {
      _error = 'Error removing stock: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}