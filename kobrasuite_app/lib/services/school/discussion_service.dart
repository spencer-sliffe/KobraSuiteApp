// lib/services/school/discussion_service.dart

import 'package:dio/dio.dart';
import '../../models/school/discussion_thread.dart';
import '../../models/school/discussion_post.dart';
import '../dio_client.dart';
import '../general/auth_service.dart';

class DiscussionService {
  final Dio _dio;
  final AuthService _authService;

  // Constructor with dependency injection
  DiscussionService(this._dio, this._authService);

  /// Retrieves discussion threads based on [scope] and [scopeId].
  Future<List<DiscussionThread>> getDiscussionThreads({
    required String scope,
    required String scopeId,
  }) async {
    final uri = '/api/discussion-threads/by_scope?scope=$scope&scope_id=$scopeId';
    try {
      final response = await _dio.get(
        uri,
        // Headers are managed by Dio's interceptor
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => DiscussionThread.fromJson(e)).toList();
      }
      throw Exception('Failed to load discussion threads: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching discussion threads: $e');
    }
  }

  /// Creates a new discussion thread.
  Future<int?> createDiscussionThread({
    required String scope,
    required int scopeId,
    required String title,
  }) async {
    final uri = '/api/discussion-threads/';
    final data = {
      'scope': scope,
      'scope_id': scopeId,
      'title': title,
      'created_by': _authService.loggedInUserId, // Ensure you have access to AuthService
    };
    try {
      final response = await _dio.post(
        uri,
        data: data,
        // Headers are managed by Dio's interceptor
      );
      if (response.statusCode == 201) {
        return response.data['id'];
      }
      throw Exception('Failed to create discussion thread: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating discussion thread: $e');
    }
  }

  /// Retrieves discussion posts for a specific thread.
  Future<List<DiscussionPost>> getDiscussionPosts(int threadId) async {
    final uri = '/api/discussion-posts/for_thread?thread_id=$threadId';
    try {
      final response = await _dio.get(
        uri,
        // Headers are managed by Dio's interceptor
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => DiscussionPost.fromJson(e)).toList();
      }
      throw Exception('Failed to load discussion posts: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching discussion posts: $e');
    }
  }

  /// Adds a new discussion post to a thread.
  Future<bool> addDiscussionPost({
    required int threadId,
    required String content,
  }) async {
    final uri = '/api/discussion-posts/';
    final data = {
      'thread': threadId,
      'author': _authService.loggedInUserId, // Ensure you have access to AuthService
      'content': content,
    };
    try {
      final response = await _dio.post(
        uri,
        data: data,
        // Headers are managed by Dio's interceptor
      );
      if (response.statusCode == 201) {
        return true;
      }
      throw Exception('Failed to add discussion post: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error adding discussion post: $e');
    }
  }
}