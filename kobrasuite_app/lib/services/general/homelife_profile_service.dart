// lib/services/general/homelife_profile_service.dart

import 'package:dio/dio.dart';
import '../../models/homelife/homelife_profile.dart';

class HomeLifeProfileService {
  final Dio _dio;

  // Constructor with dependency injection
  HomeLifeProfileService(this._dio);

  /// Retrieves the HomeLifeProfile for a specific user and HomeLifeProfile ID.
  Future<HomeLifeProfile?> getHomeLifeProfile({
    required int userPk,
    required int userProfilePk,
    required int homeLifeProfilePk,
  }) async {
    final uri = '/api/users/$userPk/profile/$userProfilePk/homelife_profile/$homeLifeProfilePk/';
    try {
      final response = await _dio.get(
        uri,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return HomeLifeProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching HomeLife Profile: $e');
    }
  }

  /// Updates the HomeLifeProfile for a specific user and homeLifeProfile ID.
  Future<HomeLifeProfile?> updateHomeLifeProfile({
    required int userPk,
    required int userProfilePk,
    required int homeLifeProfilePk,
    required Map<String, dynamic> updatedData,
  }) async {
    final uri = '/api/users/$userPk/profile/$userProfilePk/homelife_profile/$homeLifeProfilePk/';
    try {
      final response = await _dio.put(
        uri,
        data: updatedData,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return HomeLifeProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error updating HomeLife Profile: $e');
    }
  }
}