import 'package:dio/dio.dart';
import '../../models/school/assignment.dart';

class AssignmentService {
  final Dio _dio;

  AssignmentService(this._dio);

  String getAssignmentsBasePath({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
  }) {
    return '/api/users/$userPk/profile/$userProfilePk/school_profile/$schoolProfilePk/universities/$universityPk/courses/$coursePk/assignments/';
  }

  Future<List<Assignment>> getAssignmentsByCourse({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
  }) async {
    final url = getAssignmentsBasePath(
      userPk: userPk,
      userProfilePk: userProfilePk,
      schoolProfilePk: schoolProfilePk,
      universityPk: universityPk,
      coursePk: coursePk,
    );
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((e) => Assignment.fromJson(e)).toList();
    }
    throw Exception('Failed to load assignments: ${response.statusCode}');
  }

  Future<bool> addAssignment({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required Map<String, dynamic> assignmentData,
  }) async {
    final url = getAssignmentsBasePath(
      userPk: userPk,
      userProfilePk: userProfilePk,
      schoolProfilePk: schoolProfilePk,
      universityPk: universityPk,
      coursePk: coursePk,
    );
    final response = await _dio.post(url, data: assignmentData);
    return response.statusCode == 201;
  }

  Future<bool> deleteAssignment({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
    required int universityPk,
    required int coursePk,
    required int assignmentId,
  }) async {
    final url = '${getAssignmentsBasePath(userPk: userPk, userProfilePk: userProfilePk, schoolProfilePk: schoolProfilePk, universityPk: universityPk, coursePk: coursePk)}$assignmentId/';
    final response = await _dio.delete(url);
    return response.statusCode == 204;
  }
}