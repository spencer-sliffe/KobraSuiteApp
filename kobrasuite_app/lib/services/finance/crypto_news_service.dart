import 'package:dio/dio.dart';

import '../../models/finance/crypto_news.dart';

class CryptoNewsService {
  final Dio _dio;
  CryptoNewsService(this._dio);

  Future<List<CryptoNews>> fetchCryptoNews({
    String query = 'cryptocurrency',
    int page = 1,
  }) async {
    final uri = '/api/finance_extras/crypto_news/?q=$query&page=$page';
    try {
      final response = await _dio.get(uri);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('articles')) {
          final articles = data['articles'] as List;
          return articles.map((e) => CryptoNews.fromJson(e)).toList();
        }
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }
}