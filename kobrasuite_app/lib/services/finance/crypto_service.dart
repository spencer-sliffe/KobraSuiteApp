import 'package:dio/dio.dart';
import '../../../models/finance/crypto_portfolio.dart';
import '../../../models/finance/portfolio_crypto.dart';
import '../../../models/finance/favorite_crypto.dart';
import '../../../models/finance/watched_crypto.dart';

class CryptoService {
  final Dio _dio;
  CryptoService(this._dio);

  Future<CryptoPortfolio?> getCryptoPortfolio({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        return CryptoPortfolio.fromJson(response.data);
      }
    } catch (_) {}
    return null;
  }

  Future<List<PortfolioCrypto>> getPortfolioCryptos({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/cryptos/';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => PortfolioCrypto.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> addCrypto({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
    required String cryptoId,
    required String ticker,
    required double units,
    required double price,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/add_crypto/';
    final body = {
      'crypto_id': cryptoId,
      'ticker': ticker,
      'units': units,
      'price': price,
    };
    try {
      final response = await _dio.post(path, data: body);
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> removeCrypto({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
    required String cryptoId,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/remove_crypto/$cryptoId';
    try {
      final response = await _dio.delete(path);
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<List<FavoriteCrypto>> getFavoriteCryptos({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/favorite_cryptos/';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => FavoriteCrypto.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> addFavoriteCrypto({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
    required String cryptoId,
    required String ticker,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/favorite_cryptos/';
    final body = {
      'crypto_id': cryptoId,
      'ticker': ticker,
    };
    try {
      final response = await _dio.post(path, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> removeFavoriteCrypto({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
    required String cryptoId,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/favorite_cryptos/$cryptoId';
    try {
      final response = await _dio.delete(path);
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<List<WatchedCrypto>> getWatchlistCryptos({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/watchlist_cryptos/';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => WatchedCrypto.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> addWatchlistCrypto({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
    required String cryptoId,
    required String ticker,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/watchlist_cryptos/';
    final body = {
      'crypto_id': cryptoId,
      'ticker': ticker,
    };
    try {
      final response = await _dio.post(path, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> removeWatchlistCrypto({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
    required String cryptoId,
  }) async {
    final path = '/api/users/$userPk/finance_profile/$financeProfilePk/'
        'crypto_portfolio/$cryptoPortfolioPk/watchlist_cryptos/$cryptoId';
    try {
      final response = await _dio.delete(path);
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }
}
