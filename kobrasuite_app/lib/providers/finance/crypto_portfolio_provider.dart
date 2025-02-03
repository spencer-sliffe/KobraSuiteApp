import 'package:flutter/foundation.dart';
import '../../../services/finance/crypto_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/crypto_portfolio.dart';
import '../../../models/finance/portfolio_crypto.dart';

class CryptoPortfolioProvider extends ChangeNotifier {
  final CryptoService _service;
  int _userPk;
  int _financeProfilePk;
  int _cryptoPortfolioPk;
  bool _isLoading = false;
  String _errorMessage = '';
  CryptoPortfolio? _cryptoPortfolio;
  List<PortfolioCrypto> _portfolioCryptos = [];

  CryptoPortfolioProvider({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
  })  : _userPk = userPk,
        _financeProfilePk = financeProfilePk,
        _cryptoPortfolioPk = cryptoPortfolioPk,
        _service = serviceLocator<CryptoService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  CryptoPortfolio? get cryptoPortfolio => _cryptoPortfolio;
  List<PortfolioCrypto> get portfolioCryptos => _portfolioCryptos;
  int get userPk => _userPk;
  int get financeProfilePk => _financeProfilePk;
  int get cryptoPortfolioPk => _cryptoPortfolioPk;

  void update({
    required int newUserPk,
    required int newFinanceProfilePk,
    required int newCryptoPortfolioPk,
  }) {
    _userPk = newUserPk;
    _financeProfilePk = newFinanceProfilePk;
    _cryptoPortfolioPk = newCryptoPortfolioPk;
    notifyListeners();
  }

  Future<void> loadCryptoPortfolio() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final portfolio = await _service.getCryptoPortfolio(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
      );
      _cryptoPortfolio = portfolio;
    } catch (e) {
      _errorMessage = 'Error loading crypto portfolio: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPortfolioCryptos() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final cryptos = await _service.getPortfolioCryptos(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
      );
      _portfolioCryptos = cryptos;
    } catch (e) {
      _errorMessage = 'Error loading portfolio cryptos: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCrypto(String cryptoId, String ticker, double units, double price) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.addCrypto(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
        cryptoId: cryptoId,
        ticker: ticker,
        units: units,
        price: price,
      );
      if (success) {
        await loadPortfolioCryptos();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error adding crypto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeCrypto(String cryptoId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.removeCrypto(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
        cryptoId: cryptoId,
      );
      if (success) {
        _portfolioCryptos.removeWhere((c) => c.cryptoId == cryptoId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error removing crypto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}