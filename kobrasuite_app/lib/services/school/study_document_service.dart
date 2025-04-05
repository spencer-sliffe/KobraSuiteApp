// lib/services/school/study_document_service.dart

import 'package:dio/dio.dart';
import '../../models/school/study_document.dart';
import 'dart:io';

class StudyDocumentService {
  final Dio _dio;

  // Constructor with dependency injection
  StudyDocumentService(this._dio);

  /// Constructs the base path for study documents based on user, university, course, and topic IDs.
  String getStudyDocumentsBasePath({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicPk,
  }) {
    return '/api/users/$userPk/profile/$userProfilePk/school_profile/$schoolProfilePk'
        '/universities/$universityPk/courses/$coursePk/topics/$topicPk/study_documents/';
  }

  /// Constructs the URL for a specific study document.
  String getStudyDocumentDetailPath({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicPk,
    required int studyDocumentPk,
  }) {
    return '/api/users/$userPk/profile/$userProfilePk/school_profile/'
        '$schoolProfilePk/universities/$universityPk/courses/$coursePk/'
        'topics/$topicPk/study_documents/$studyDocumentPk/';
  }

  /// Retrieves study documents for a specific topic.
  Future<List<StudyDocument>> getStudyDocumentsByTopic({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicPk,
  }) async {
    final url = getStudyDocumentsBasePath(
      userPk: userPk,
      userProfilePk: userProfilePk,
      schoolProfilePk: schoolProfilePk,
      universityPk: universityPk,
      coursePk: coursePk,
      topicPk: topicPk,
    );
    try {
      final response = await _dio.get(
        url,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => StudyDocument.fromJson(e)).toList();
      }
      throw Exception('Failed to load study documents: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching study documents: $e');
    }
  }

  /// Uploads a new study document to a specific topic.
  Future<StudyDocument?> uploadStudyDocument({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicPk,
    required File file,
    Function(int, int)? onProgress,
  }) async {
    final url = getStudyDocumentsBasePath(
      userPk: userPk,
      userProfilePk: userProfilePk,
      schoolProfilePk: schoolProfilePk,
      universityPk: universityPk,
      coursePk: coursePk,
      topicPk: topicPk,
    );
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
        // Add other fields if necessary
      });

      final response = await _dio.post(
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

      if (response.statusCode == 201) {
        return StudyDocument.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to upload study document: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error uploading study document: $e');
    }
  }

  /// Updates an existing study document.
  Future<StudyDocument?> updateStudyDocument({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicPk,
    required int studyDocumentPk,
    required Map<String, dynamic> updatedData,
  }) async {
    final url = getStudyDocumentDetailPath(
      userPk: userPk,
      userProfilePk: userProfilePk,
      schoolProfilePk: schoolProfilePk,
      universityPk: universityPk,
      coursePk: coursePk,
      topicPk: topicPk,
      studyDocumentPk: studyDocumentPk,
    );
    try {
      final response = await _dio.put(
        url,
        data: updatedData,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return StudyDocument.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to update study document: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating study document: $e');
    }
  }

  /// Deletes a study document.
  Future<bool> deleteStudyDocument({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicPk,
    required int studyDocumentPk,
  }) async {
    final url = getStudyDocumentDetailPath(
      userPk: userPk,
      userProfilePk: userProfilePk,
      schoolProfilePk: schoolProfilePk,
      universityPk: universityPk,
      coursePk: coursePk,
      topicPk: topicPk,
      studyDocumentPk: studyDocumentPk,
    );
    try {
      final response = await _dio.delete(
        url,
        // Headers are managed by DioClient's interceptor
      );
      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting study document: $e');
    }
  }
}