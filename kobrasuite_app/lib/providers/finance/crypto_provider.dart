import 'package:flutter/foundation.dart';
import '../../../services/finance/crypto_service.dart';
import '../../../services/service_locator.dart';
import '../../../models/finance/favorite_crypto.dart';
import '../../../models/finance/watched_crypto.dart';

class CryptoProvider extends ChangeNotifier {
  final CryptoService _service;
  int _userPk;
  int _financeProfilePk;
  int _cryptoPortfolioPk;
  bool _isLoading = false;
  String _errorMessage = '';
  List<FavoriteCrypto> _favoriteCryptos = [];
  List<WatchedCrypto> _watchlistCryptos = [];

  CryptoProvider({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
  })  : _userPk = userPk,
        _financeProfilePk = financeProfilePk,
        _cryptoPortfolioPk = cryptoPortfolioPk,
        _service = serviceLocator<CryptoService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<FavoriteCrypto> get favoriteCryptos => _favoriteCryptos;
  List<WatchedCrypto> get watchlistCryptos => _watchlistCryptos;
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

  Future<void> loadFavoriteCryptos() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final list = await _service.getFavoriteCryptos(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
      );
      _favoriteCryptos = list;
    } catch (e) {
      _errorMessage = 'Error loading favorite cryptos: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addFavoriteCrypto(String cryptoId, String ticker) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.addFavoriteCrypto(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
        cryptoId: cryptoId,
        ticker: ticker,
      );
      if (success) {
        await loadFavoriteCryptos();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error adding favorite crypto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavoriteCrypto(String cryptoId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.removeFavoriteCrypto(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
        cryptoId: cryptoId,
      );
      if (success) {
        _favoriteCryptos.removeWhere((c) => c.cryptoId == cryptoId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error removing favorite crypto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadWatchlistCryptos() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final list = await _service.getWatchlistCryptos(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
      );
      _watchlistCryptos = list;
    } catch (e) {
      _errorMessage = 'Error loading watchlist cryptos: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addWatchlistCrypto(String cryptoId, String ticker) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.addWatchlistCrypto(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
        cryptoId: cryptoId,
        ticker: ticker,
      );
      if (success) {
        await loadWatchlistCryptos();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error adding watchlist crypto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeWatchlistCrypto(String cryptoId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final success = await _service.removeWatchlistCrypto(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        cryptoPortfolioPk: _cryptoPortfolioPk,
        cryptoId: cryptoId,
      );
      if (success) {
        _watchlistCryptos.removeWhere((c) => c.cryptoId == cryptoId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error removing watchlist crypto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}