// lib/services/general/user_profile_service.dart

import 'package:dio/dio.dart';
import '../../models/general/user_profile.dart';

class UserProfileService {
  final Dio _dio;

  // Constructor with dependency injection
  UserProfileService(this._dio);

  /// Retrieves the UserProfile for a specific user and userProfile ID.
  Future<UserProfile?> getUserProfile({
    required int userPk,
    required int userProfilePk,
  }) async {
    final uri = '/api/users/$userPk/profile/$userProfilePk/';
    try {
      final response = await _dio.get(
        uri,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching User Profile: $e');
    }
  }

  /// Updates the UserProfile for a specific user and userProfile ID.
  Future<UserProfile?> updateUserProfile({
    required int userPk,
    required int userProfilePk,
    required Map<String, dynamic> updatedData,
  }) async {
    final uri = '/api/users/$userPk/profile/$userProfilePk/';
    try {
      final response = await _dio.put(
        uri,
        data: updatedData,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error updating User Profile: $e');
    }
  }
}