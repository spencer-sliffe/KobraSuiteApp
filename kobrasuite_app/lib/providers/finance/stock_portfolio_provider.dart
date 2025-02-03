import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../services/finance/stock_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/stock_portfolio.dart';
import '../../../models/finance/portfolio_stock.dart';

class StockPortfolioProvider extends ChangeNotifier {
  final StockService _service;
  int _userPk;
  int _financeProfilePk;
  int _stockPortfolioPk;
  bool _isLoading = false;
  String _errorMessage = '';
  StockPortfolio? _stockPortfolio;
  List<PortfolioStock> _portfolioStocks = [];

  StockPortfolioProvider({
    required int userPk,
    required int financeProfilePk,
    required int stockPortfolioPk,
  })  : _userPk = userPk,
        _financeProfilePk = financeProfilePk,
        _stockPortfolioPk = stockPortfolioPk,
        _service = serviceLocator<StockService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  StockPortfolio? get stockPortfolio => _stockPortfolio;
  List<PortfolioStock> get portfolioStocks => _portfolioStocks;
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

  Future<void> loadStockPortfolio() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final portfolio = await _service.getStockPortfolio(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
      );
      _stockPortfolio = portfolio;
    } catch (e) {
      _errorMessage = 'Error loading stock portfolio: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPortfolioStocks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final stocks = await _service.getPortfolioStocks(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
      );
      _portfolioStocks = stocks;
    } catch (e) {
      _errorMessage = 'Error loading portfolio stocks: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addStock(String ticker, double shares, {String? purchaseDateIso}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.addStock(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
        ticker: ticker,
        numShares: shares,
        purchaseDateIso: purchaseDateIso,
      );
      if (success) {
        await loadPortfolioStocks();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error adding stock: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeStock(String ticker) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.removeStock(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        stockPortfolioPk: _stockPortfolioPk,
        ticker: ticker,
      );
      if (success) {
        _portfolioStocks.removeWhere((s) => s.ticker == ticker);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error removing stock: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}