import 'package:dio/dio.dart';
import '../../models/school/topic.dart';

class TopicService {
  final Dio _dio;

  TopicService(this._dio);

  Future<List<Topic>> getTopicsByCourse({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
  }) async {
    try {
      final uri = '/api/users/$userPk/profile/$userProfilePk/school_profile/'
          '$schoolProfilePk/universities/$universityPk/courses/$coursePk/topics/';
      final response = await _dio.get(uri);
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((e) => Topic.fromJson(e)).toList();
      }
      throw Exception('Failed to fetch topics: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching topics: $e');
    }
  }

  Future<Topic> addTopic({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required String name,
  }) async {
    try {
      final uri = '/api/users/$userPk/profile/$userProfilePk/school_profile/'
          '$schoolProfilePk/universities/$universityPk/courses/'
          '$coursePk/topics/add_new_topic/';
      final payload = {
        'name': name,
        'course': coursePk,
      };
      final response = await _dio.post(uri, data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Topic.fromJson(response.data);
      }
      throw Exception('Failed to add topic: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error adding topic: $e');
    }
  }

  Future<bool> deleteTopic({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicId,
  }) async {
    try {
      final uri = '/api/users/$userPk/profile/$userProfilePk/school_profile/'
          '$schoolProfilePk/universities/$universityPk/courses/'
          '$coursePk/topics/$topicId/remove_topic/';
      final response = await _dio.delete(uri);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting topic: $e');
    }
  }

  Future<Topic> updateTopic({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicId,
    required String newName,
  }) async {
    try {
      final uri = '/api/users/$userPk/profile/$userProfilePk/school_profile/'
          '$schoolProfilePk/universities/$universityPk/courses/'
          '$coursePk/topics/$topicId/update_topic';
      final payload = {
        'name': newName,
      };
      final response = await _dio.put(uri, data: payload);
      if (response.statusCode == 200) {
        return Topic.fromJson(response.data);
      }
      throw Exception('Failed to update topic: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating topic: $e');
    }
  }
}