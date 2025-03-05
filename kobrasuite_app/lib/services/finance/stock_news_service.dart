import 'package:dio/dio.dart';
import '../../models/finance/stock_news.dart';

class StockNewsService {
  final Dio _dio;
  StockNewsService(this._dio);

  Future<List<StockNews>> fetchStockNews({String query = 'stocks', int page = 1}) async {
    final uri = '/api/misc_invest/stock_news/?q=$query&page=$page';
    final response = await _dio.get(uri);
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('articles')) {
        final articles = data['articles'] as List;
        return articles.map((e) => StockNews.fromJson(e)).toList();
      }
    }
    return [];
  }
}