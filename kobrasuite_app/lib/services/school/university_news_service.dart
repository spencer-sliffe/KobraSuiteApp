import 'package:dio/dio.dart';
import '../../models/school/university_news.dart';

class UniversityNewsService {
  final Dio _dio;

  UniversityNewsService(this._dio);

  Future<List<UniversityNews>> fetchTrendingNews(String universityName) async {
    // Simulated API call – in a real implementation, hit an endpoint.
    await Future.delayed(const Duration(seconds: 1));
    return [
      UniversityNews(
        title: "$universityName announces new research center",
        summary: "The university unveiled plans for a state-of-the-art research center focusing on sustainable energy.",
        imageUrl: "https://loremflickr.com/320/240/research",
        publishedAt: "2025-01-15",
      ),
      UniversityNews(
        title: "Campus festival draws record crowds",
        summary: "Students and alumni celebrate at the annual festival with music, food, and games.",
        imageUrl: "https://loremflickr.com/320/240/festival",
        publishedAt: "2025-01-10",
      ),
      UniversityNews(
        title: "$universityName ranked among top universities",
        summary: "New rankings place the university among the top institutions for innovation and research.",
        imageUrl: "https://loremflickr.com/320/240/ranking",
        publishedAt: "2025-01-05",
      ),
    ];
  }
}