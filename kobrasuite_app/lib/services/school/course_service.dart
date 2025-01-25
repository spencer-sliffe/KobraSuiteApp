// File location: lib/services/school/course_service.dart

// 1) Now that the backend returns {"detail": "...", "course": {...}} upon success,
//    we parse the "course" key for a successful 200/201 response.

/// lib/services/school/course_service.dart
library;

import 'package:dio/dio.dart';
import '../../models/school/course.dart';

class CourseService {
  final Dio _dio;

  // Constructor with dependency injection
  CourseService(this._dio);

  Future<Course> createCourseInUniversity({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    required Map<String, dynamic> courseData,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk'
        '/universities/$universityPk/courses/add_new_course/';
    try {
      final response = await _dio.post(uri, data: courseData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('course')) {
          // Parse the newly created or existing course
          return Course.fromJson(data['course'] as Map<String, dynamic>);
        } else {
          throw Exception(
              'Server did not return "course" data. Response: $data');
        }
      }
      throw Exception('Failed to create course: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating course: $e');
    }
  }

  Future<List<Course>> searchCoursesInUniversity({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    String? query,
  }) async {
    final queryParameters = <String, String>{};
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk'
        '/universities/$universityPk/courses/search/';
    try {
      final response = await _dio.get(uri, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data
            .map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error searching courses: $e');
    }
  }

  Future<void> addCourseToSchoolProfile({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    required int courseId,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk'
        '/universities/$universityPk/courses/add_course_to_profile/';
    final body = {'course_id': courseId};
    try {
      final response = await _dio.post(uri, data: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add course to profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding course to profile: $e');
    }
  }

  Future<void> removeCourseFromSchoolProfile({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    required int courseId,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk'
        '/universities/$universityPk/courses/remove_course_from_profile/';
    final body = {'course_id': courseId};
    try {
      final response = await _dio.post(uri, data: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to remove course from profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing course from profile: $e');
    }
  }

  Future<Map<String, dynamic>> verifyCourse({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    required Map<String, dynamic> courseData,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk'
        '/universities/$universityPk/verify_course_existence/verify_course/';
    final response = await _dio.post(uri, data: courseData);
    if (response.statusCode == 200) {
      return response.data;
    }
    return {"foundExactMatch": false, "correctedCourseData": null};
  }
}