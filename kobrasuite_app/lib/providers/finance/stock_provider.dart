import 'package:flutter/foundation.dart';
import '../../../services/finance/stock_service.dart';
import '../../../services/service_locator.dart';
import '../../models/finance/watchlist_stock.dart';

class StockProvider extends ChangeNotifier {
  final StockService _service;
  int _userPk;
  int _userProfilePk;
  int _financeProfilePk;
  int _stockPortfolioPk;

  bool _isLoading = false;
  String _errorMessage = '';
  List<WatchlistStock> _watchlistStocks = [];

  StockProvider({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
    required int stockPortfolioPk,
  })  : _userPk = userPk,
        _userProfilePk = userProfilePk,
        _financeProfilePk = financeProfilePk,
        _stockPortfolioPk = stockPortfolioPk,
        _service = serviceLocator<StockService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<WatchlistStock> get watchlistStocks => _watchlistStocks;

  int get userPk => _userPk;
  int get userProfilePk => _userProfilePk;
  int get financeProfilePk => _financeProfilePk;
  int get stockPortfolioPk => _stockPortfolioPk;

  void update({
    required int newUserPk,
    required int newUserProfilePk,
    required int newFinanceProfilePk,
    required int newStockPortfolioPk,
  }) {
    _userPk = newUserPk;
    _userProfilePk = newUserProfilePk;
    _financeProfilePk = newFinanceProfilePk;
    _stockPortfolioPk = newStockPortfolioPk;
    notifyListeners();
  }

  Future<void> loadWatchlistStocks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final list = await _service.getWatchlistStocks(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
      );
      _watchlistStocks = list;
    } catch (e) {
      _errorMessage = 'Error loading watchlist stocks: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addWatchlistStock(String ticker) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.addWatchlistStock(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
        ticker: ticker,
      );
      if (success) {
        await loadWatchlistStocks();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error adding watchlist stock: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeWatchlistStock(int watchlistStockId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.removeWatchlistStock(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
        watchlistStockId: watchlistStockId,
      );
      if (success) {
        _watchlistStocks.removeWhere((w) => w.id == watchlistStockId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error removing watchlist stock: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}