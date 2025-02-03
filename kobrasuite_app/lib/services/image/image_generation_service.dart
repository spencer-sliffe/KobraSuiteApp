/* File: lib/services/image_generation_service.dart */
import 'package:dio/dio.dart';

class ImageGenerationService {
  final Dio _dio;
  ImageGenerationService(this._dio);

  Future<List<String>> generateBannerColors(String prompt) async {
    final response = await _dio.post('/api/image-generation/generate/', data: {'prompt': prompt});
    if (response.statusCode == 200 && response.data != null && response.data['color_palette'] != null) {
      return List<String>.from(response.data['color_palette']);
    }
    throw Exception('Banner color generation failed');
  }
}