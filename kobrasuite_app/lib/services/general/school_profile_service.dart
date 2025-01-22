// lib/services/school/school_profile_service.dart

import 'package:dio/dio.dart';
import '../../models/school/school_profile.dart';

class SchoolProfileService {
  final Dio _dio;

  // Constructor with dependency injection
  SchoolProfileService(this._dio);

  /// Retrieves the SchoolProfile for a specific user and schoolProfile ID.
  Future<SchoolProfile?> getSchoolProfile({
    required int userPk,
    required int schoolProfilePk,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk/';
    try {
      final response = await _dio.get(
        uri,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return SchoolProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching School Profile: $e');
    }
  }

  /// Updates the SchoolProfile for a specific user and schoolProfile ID.
  Future<SchoolProfile?> updateSchoolProfile({
    required int userPk,
    required int schoolProfilePk,
    required Map<String, dynamic> updatedData,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk/';
    try {
      final response = await _dio.put(
        uri,
        data: updatedData,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return SchoolProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error updating School Profile: $e');
    }
  }
}