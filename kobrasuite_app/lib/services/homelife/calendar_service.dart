import 'package:dio/dio.dart';
import 'package:kobrasuite_app/models/homelife/shared_calendar_event.dart';

class CalendarService {
  final Dio _dio;

  CalendarService(this._dio);

  // Bank Accounts
  Future<List<SharedCalendarEvent>> getCalendarEvents({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/calendar_events/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => SharedCalendarEvent.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createCalendarEvent({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String title,
    required String startDateTime,
    required String endDateTime,
    required String description,
    required String location
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/calendar_events/';
      final body = {
        'household': householdPk,
        'title': title,
        'start_datetime': startDateTime,
        'end_datetime': endDateTime,
        'description': description,
        'location': location,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteCalendarEvent({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int calendarEventId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/calendar_events/$calendarEventId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}