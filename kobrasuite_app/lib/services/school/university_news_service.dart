import 'package:dio/dio.dart';
import '../../models/school/university_news.dart';

class UniversityNewsService {
  final Dio _dio;

  UniversityNewsService(this._dio);

  Future<List<UniversityNews>> fetchTrendingNews({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required String universityName,
    int page = 1,
  }) async {
    final uri = '/api/users/$userPk/profile/$userProfilePk/'
        'school_profile/$schoolProfilePk/universities/$universityPk/news';
    try {
      final response = await _dio.get(
        uri,
        queryParameters: {
          'page': page.toString(),
          'universityName': universityName, // <--- pass the name
        },
      );
      if (response.statusCode == 200) {
        // The NewsAPI JSON typically has a top-level "articles" array
        final data = response.data as Map<String, dynamic>;
        final articles = data['articles'] as List<dynamic>?;

        if (articles == null) {
          return [];
        }

        return articles.map((json) {
          return UniversityNews(
            title: json['title'] ?? 'No Title',
            summary: json['description'] ?? '',
            imageUrl: json['urlToImage'] ?? '',
            publishedAt: json['publishedAt'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch news: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('News service error: ${e.message}');
    }
  }
}