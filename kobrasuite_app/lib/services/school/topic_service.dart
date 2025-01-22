import 'package:dio/dio.dart';
import '../../models/school/topic.dart';

class TopicService {
  final Dio _dio;

  TopicService(this._dio);

  Future<List<Topic>> getTopicsByCourse({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk/universities/$universityPk/courses/$coursePk/topics/';
    final response = await _dio.get(uri);
    if (response.statusCode == 200) {
      List data = response.data;
      return data.map((e) => Topic.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch topics: ${response.statusCode}');
  }

  Future<Topic> addTopic({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required String name,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk/universities/$universityPk/courses/$coursePk/topics/add_new_topic/';
    final payload = {
      'name': name,
      'course': coursePk,
    };
    final response = await _dio.post(uri, data: payload);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Topic.fromJson(response.data);
    }
    throw Exception('Failed to add topic: ${response.statusCode}');
  }

  Future<bool> deleteTopic({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicId,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk/universities/$universityPk/courses/$coursePk/topics/$topicId/remove_study_document/';
    final response = await _dio.delete(uri);
    return response.statusCode == 200;
  }

  Future<Topic> updateTopic({
    required int userPk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int topicId,
    required String newName,
  }) async {
    final uri = '/api/users/$userPk/school_profile/$schoolProfilePk/universities/$universityPk/courses/$coursePk/topics/$topicId/update_study_document/';
    final payload = {
      'name': newName,
    };
    final response = await _dio.put(uri, data: payload);
    if (response.statusCode == 200) {
      return Topic.fromJson(response.data);
    }
    throw Exception('Failed to update topic: ${response.statusCode}');
  }
}