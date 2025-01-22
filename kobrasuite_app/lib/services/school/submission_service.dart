// lib/services/school/submission_service.dart

import 'package:dio/dio.dart';
import '../../models/school/submission.dart';
import 'dart:io';

class SubmissionService {
  final Dio _dio;

  // Constructor with dependency injection
  SubmissionService(this._dio);

  /// Constructs the base path for submissions based on user, university, course, and assignment IDs.
  String getSubmissionsBasePath({
    required int userPk,
    required int universityPk,
    required int coursePk,
    required int assignmentPk,
  }) {
    return '/api/users/$userPk/school_profile/universities/$universityPk/courses/$coursePk/assignments/$assignmentPk/submissions/';
  }

  /// Constructs the URL for a specific submission.
  String getSubmissionDetailPath({
    required int userPk,
    required int universityPk,
    required int coursePk,
    required int assignmentPk,
    required int submissionPk,
  }) {
    return '/api/users/$userPk/school_profile/universities/$universityPk/courses/$coursePk/assignments/$assignmentPk/submissions/$submissionPk/';
  }

  /// Constructs the URL for adding a comment to a submission.
  String getAddCommentPath({
    required int userPk,
    required int universityPk,
    required int coursePk,
    required int assignmentPk,
    required int submissionPk,
  }) {
    return '/api/users/$userPk/school_profile/universities/$universityPk/courses/$coursePk/assignments/$assignmentPk/submissions/$submissionPk/add_comment/';
  }

  /// Retrieves submissions for a specific assignment.
  Future<List<Submission>> getSubmissionsByAssignment({
    required int userPk,
    required int universityPk,
    required int coursePk,
    required int assignmentPk,
  }) async {
    final url = getSubmissionsBasePath(
      userPk: userPk,
      universityPk: universityPk,
      coursePk: coursePk,
      assignmentPk: assignmentPk,
    );
    try {
      final response = await _dio.get(
        url,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => Submission.fromJson(e)).toList();
      }
      throw Exception('Failed to load submissions: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// Creates a new submission for an assignment.
  Future<Submission?> createSubmission({
    required int userPk,
    required int universityPk,
    required int coursePk,
    required int assignmentPk,
    required Map<String, dynamic> submissionData,
  }) async {
    final url = getSubmissionsBasePath(
      userPk: userPk,
      universityPk: universityPk,
      coursePk: coursePk,
      assignmentPk: assignmentPk,
    );
    try {
      final response = await _dio.post(
        url,
        data: submissionData,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 201) {
        return Submission.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create submission: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating submission: $e');
    }
  }

  /// Uploads an answer file to a submission.
  Future<bool> uploadAnswer({
    required int userPk,
    required int universityPk,
    required int coursePk,
    required int assignmentPk,
    required int submissionPk,
    required File file,
    Function(int, int)? onProgress,
  }) async {
    try {
      final url = getSubmissionDetailPath(
        userPk: userPk,
        universityPk: universityPk,
        coursePk: coursePk,
        assignmentPk: assignmentPk,
        submissionPk: submissionPk,
      );
      FormData formData = FormData.fromMap({
        'answer_file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await _dio.patch(
        url,
        data: formData,
        options: Options(
          headers: {
            // 'Authorization' header is managed by DioClient's interceptor
            // 'Content-Type' is set automatically by Dio when using FormData
          },
        ),
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw Exception('Failed to upload answer file: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error uploading answer file: $e');
    }
  }

  /// Adds a comment to a submission.
  Future<bool> addComment({
    required int userPk,
    required int universityPk,
    required int coursePk,
    required int assignmentPk,
    required int submissionPk,
    required String comment,
  }) async {
    final url = getAddCommentPath(
      userPk: userPk,
      universityPk: universityPk,
      coursePk: coursePk,
      assignmentPk: assignmentPk,
      submissionPk: submissionPk,
    );
    try {
      final response = await _dio.post(
        url,
        data: {'comment': comment},
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      throw Exception('Failed to add comment: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  /// Retrieves details of a specific submission.
  Future<Submission?> getSubmissionDetail({
    required int userPk,
    required int universityPk,
    required int coursePk,
    required int assignmentPk,
    required int submissionPk,
  }) async {
    final url = getSubmissionDetailPath(
      userPk: userPk,
      universityPk: universityPk,
      coursePk: coursePk,
      assignmentPk: assignmentPk,
      submissionPk: submissionPk,
    );
    try {
      final response = await _dio.get(
        url,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return Submission.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch submission details: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching submission details: $e');
    }
  }
}