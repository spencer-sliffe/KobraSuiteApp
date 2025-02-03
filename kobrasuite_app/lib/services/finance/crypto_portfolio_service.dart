import 'package:dio/dio.dart';
import '../../models/finance/crypto_portfolio.dart';

class CryptoPortfolioService {
  final Dio _dio;
  CryptoPortfolioService(this._dio);

  Future<CryptoPortfolio?> fetchCryptoPortfolio({
    required int userPk,
    required int financeProfilePk,
    required int cryptoPortfolioPk,
  }) async {
    final uri = '/api/users/$userPk/finance_profile/$financeProfilePk/crypto_portfolio/$cryptoPortfolioPk/';
    try {
      final response = await _dio.get(uri);
      if (response.statusCode == 200) {
        return CryptoPortfolio.fromJson(response.data);
      }
      return null;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> createCryptoPortfolioIfNone({
    required int userPk,
    required int financeProfilePk,
  }) async {
    final uri = '/api/users/$userPk/finance_profile/$financeProfilePk/crypto_portfolio/';
    try {
      // This endpoint might handle creation if not exists
      final response = await _dio.post(uri);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}