import 'package:dio/dio.dart';
import '../../models/homelife/medical_appointment.dart';
import '../../models/homelife/medication.dart';

class HealthService {
  final Dio _dio;

  HealthService(this._dio);

  Future<List<Medication>> getMedications({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/medications/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => Medication.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createMedication({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/medications/';
      final body = {
        'homelife_profile': homelifeProfilePk,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteMedication({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk,
    required int medicationId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/medications/$medicationId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MedicalAppointment>> getMedicalAppointment({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/medical_appointments/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => MedicalAppointment.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createMedicalAppointment({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/medical_appointments/';
      final body = {
        'homelife_profile': homelifeProfilePk,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteMedicalAppointment({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk,
    required int medicalAppointmentId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk'
          '/medical_appointments/$medicalAppointmentId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}