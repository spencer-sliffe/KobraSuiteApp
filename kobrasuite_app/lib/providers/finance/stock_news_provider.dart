import 'package:flutter/foundation.dart';
import '../../models/finance/stock_news.dart';
import '../../services/finance/stock_news_service.dart';
import '../../services/service_locator.dart';

class StockNewsProvider extends ChangeNotifier {
  final StockNewsService _newsService;
  bool _isLoading = false;
  String _errorMessage = '';
  List<StockNews> _articles = [];

  StockNewsProvider()
      : _newsService = serviceLocator<StockNewsService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<StockNews> get articles => _articles;

  Future<void> fetchNews({String query = 'stocks', int page = 1}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final data = await _newsService.fetchStockNews(query: query, page: page);
      _articles = data;
    } catch (e) {
      _errorMessage = 'Error fetching stock news: $e';
    }
    _isLoading = false;
    notifyListeners();
  }
}