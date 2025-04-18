import 'package:dio/dio.dart';
import '../../models/homelife/workout_routine.dart';

class PersonalHomelifeService {
  final Dio _dio;
  PersonalHomelifeService(this._dio);

  Future<List<WorkoutRoutine>> getWorkoutRoutines({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/workout_routines/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => WorkoutRoutine.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createWorkoutRoutine({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String title,
    required String description,
    required String schedule,
    required String exercises
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/workout_routines/';
      final body = {
        'household': householdPk,
        'title': title,
        'description': description,
        'schedule': schedule,
        'exercises': exercises
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteWorkoutRoutine({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int workoutRoutineId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/calendar_events/$workoutRoutineId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}