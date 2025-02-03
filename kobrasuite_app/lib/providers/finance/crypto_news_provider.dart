import 'package:flutter/foundation.dart';
import '../../models/finance/crypto_news.dart';
import '../../services/finance/crypto_news_service.dart';
import '../../services/service_locator.dart';

class CryptoNewsProvider extends ChangeNotifier {
  final CryptoNewsService _newsService;
  bool _isLoading = false;
  String _errorMessage = '';
  List<CryptoNews> _articles = [];

  CryptoNewsProvider()
      : _newsService = serviceLocator<CryptoNewsService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<CryptoNews> get articles => _articles;

  Future<void> fetchNews({String query = 'cryptocurrency', int page = 1}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final data = await _newsService.fetchCryptoNews(query: query, page: page);
      _articles = data;
    } catch (e) {
      _errorMessage = 'Error fetching crypto news: $e';
    }
    _isLoading = false;
    notifyListeners();
  }
}