// lib/services/school/university_service.dart

import 'package:dio/dio.dart';
import '../../config.dart';
import '../../models/school/course.dart';
import '../../models/school/university.dart';

class UniversityService {
  static String get baseUrl => Config.baseUrl;

  final Dio _dio;

  UniversityService(this._dio);

  /// Searches for universities based on [name] and [country].
  Future<List<University>> searchUniversities({
    required int userPk,
    required int schoolProfilePk,
    String? name,
    String? country,
  }) async {
    final queryParameters = <String, String>{};
    if (name != null && name.isNotEmpty) queryParameters['query'] = name;
    if (country != null && country.isNotEmpty) queryParameters['country'] = country;
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk/universities/search/';
    try {
      final response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((e) => University.fromJson(e)).toList();
      } else {
        throw Exception('Failed to search universities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching universities: $e');
    }
  }

  /// Sets the user's university.
  Future<University> setUserUniversity({
    required int userPk,
    required int schoolProfilePk,
    required University university,
  }) async {
    final uri =
        '/api/users/$userPk/school_profile/$schoolProfilePk/set_university/';
    final body = {
      'name': university.name,
      'country': university.country,
      'domain': university.domain,
      'website': university.website ?? '',
    };
    try {
      final response = await _dio.post(
        uri,
        data: body,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return University.fromJson(response.data['university_detail']);
      } else {
        throw Exception('Failed to set university: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error setting university: $e');
    }
  }

  /// Removes the user's university.
  Future<bool> removeUserUniversity({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
  }) async {
    final uri =
        '/api/users/$userPk/school_profile/$schoolProfilePk/universities/$universityPk/remove_university/';
    try {
      final response = await _dio.post(
        uri,
        // Headers are managed by DioClient's interceptor
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error removing university: $e');
    }
  }

  /// Retrieves all courses for a specific university.
  Future<List<Course>> getAllUniversityCourses({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
  }) async {
    final uri =
        '/api/users/$userPk/school_profile/$schoolProfilePk/universities/$universityPk/courses/search/';
    try {
      final response = await _dio.get(
        uri,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((e) => Course.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get university courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching university courses: $e');
    }
  }
}