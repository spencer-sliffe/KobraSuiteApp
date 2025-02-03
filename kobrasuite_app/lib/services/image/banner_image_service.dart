// File: lib/services/banner_image_service.dart
import 'package:kobrasuite_app/services/service_locator.dart';
import 'image_generation_service.dart';

/// BannerImageService provides methods to retrieve either a color palette for an abstract animated banner
/// or a static banner image URL for a given prompt.
class BannerImageService {
  Future<List<String>> getBannerColors(String prompt) async {
    try {
      final imageGenService = serviceLocator<ImageGenerationService>();
      return await imageGenService.generateBannerColors(prompt);
    } catch (e) {
      // Fallback palette (e.g. Crimson and Blue for University of Kansas)
      return ["#E8000D", "#0051BA"];
    }
  }
}