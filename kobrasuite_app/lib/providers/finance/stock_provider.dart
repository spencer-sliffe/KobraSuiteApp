import 'package:flutter/foundation.dart';
import '../../../services/finance/stock_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/favorite_stock.dart';
import '../../../models/finance/watched_stock.dart';

class StockProvider extends ChangeNotifier {
  final StockService _service;
  int _userPk;
  int _financeProfilePk;
  int _stockPortfolioPk;
  bool _isLoading = false;
  String _errorMessage = '';
  List<FavoriteStock> _favoriteStocks = [];
  List<WatchedStock> _watchlistStocks = [];

  StockProvider({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
  })  : _userPk = userPk,
        _financeProfilePk = financeProfilePk,
        _stockPortfolioPk = stockPortfolioPk,
        _service = serviceLocator<StockService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<FavoriteStock> get favoriteStocks => _favoriteStocks;
  List<WatchedStock> get watchlistStocks => _watchlistStocks;
  int get userPk => _userPk;
  int get financeProfilePk => _financeProfilePk;
  int get stockPortfolioPk => _stockPortfolioPk;

  void update({
    required int newUserPk,
    required int newFinanceProfilePk,
    required int newStockPortfolioPk,
  }) {
    _userPk = newUserPk;
    _financeProfilePk = newFinanceProfilePk;
    _stockPortfolioPk = newStockPortfolioPk;
    notifyListeners();
  }

  Future<void> loadFavoriteStocks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final list = await _service.getFavoriteStocks(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
      );
      _favoriteStocks = list;
    } catch (e) {
      _errorMessage = 'Error loading favorite stocks: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addFavoriteStock(String ticker) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.addFavoriteStock(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
        ticker: ticker,
      );
      if (success) {
        await loadFavoriteStocks();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error adding favorite stock: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavoriteStock(String ticker) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.removeFavoriteStock(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
        ticker: ticker,
      );
      if (success) {
        _favoriteStocks.removeWhere((f) => f.ticker == ticker);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error removing favorite stock: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadWatchlistStocks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final list = await _service.getWatchlistStocks(
        userPk: _userPk,
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
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
        ticker: ticker,
      );
      if (success) {
        await loadWatchlistStocks();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error adding watchlist stock: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeWatchlistStock(String ticker) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.removeWatchlistStock(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
        ticker: ticker,
      );
      if (success) {
        _watchlistStocks.removeWhere((w) => w.ticker == ticker);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error removing watchlist stock: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}