// lib/services/general/work_profile_service.dart

import 'package:dio/dio.dart';
import '../../models/work/work_profile.dart';

class WorkProfileService {
  final Dio _dio;

  // Constructor with dependency injection
  WorkProfileService(this._dio);

  /// Retrieves the WorkProfile for a specific user and WorkProfile ID.
  Future<WorkProfile?> getWorkProfile({
    required int userPk,
    required int workProfilePk,
  }) async {
    final uri = '/api/users/$userPk/work_profile/$workProfilePk/';
    try {
      final response = await _dio.get(
        uri,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return WorkProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching User Profile: $e');
    }
  }

  Future<WorkProfile?> updateWorkProfile({
    required int userPk,
    required int workProfilePk,
    required Map<String, dynamic> updatedData,
  }) async {
    final uri = '/api/users/$userPk/work_profile/$workProfilePk/';
    try {
      final response = await _dio.put(
        uri,
        data: updatedData,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return WorkProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error updating User Profile: $e');
    }
  }
}