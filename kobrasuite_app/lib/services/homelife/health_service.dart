import 'package:dio/dio.dart';
import '../../models/homelife/medical_appointment.dart';
import '../../models/homelife/medication.dart';

class HealthService {
  final Dio _dio;
  HealthService(this._dio);

  // ───────────────────────── MEDICATIONS ──────────────────────────

  Future<List<Medication>> getMedications({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
        '$homelifeProfilePk/households/$householdPk/medications/';

    final res = await _dio.get(url);
    if (res.statusCode == 200) {
      final results = (res.data as Map<String, dynamic>)['results'] as List;
      return results.map((e) => Medication.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createMedication({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String name,
    required String dosage,
    required String frequency,
    String? nextDoseIso,          // nullable
    String notes = '',
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
        '$homelifeProfilePk/households/$householdPk/medications/';

    final body = {
      'household' : householdPk,
      'name'      : name,
      'dosage'    : dosage,
      'frequency' : frequency,
      'next_dose' : nextDoseIso,
      'notes'     : notes,
      'homelife_profile': homelifeProfilePk,
    };

    final res = await _dio.post(url, data: body);
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> deleteMedication({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int medicationId,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
        '$homelifeProfilePk/households/$householdPk/medications/$medicationId';

    final res = await _dio.delete(url);
    return res.statusCode == 204 || res.statusCode == 200;
  }

  // ─────────────────────── MEDICAL APPOINTMENTS ───────────────────

  Future<List<MedicalAppointment>> getMedicalAppointments({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
        '$homelifeProfilePk/households/$householdPk/medical_appointments/';

    final res = await _dio.get(url);
    if (res.statusCode == 200) {
      final results = (res.data as Map<String, dynamic>)['results'] as List;
      return results.map((e) => MedicalAppointment.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createMedicalAppointment({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String title,
    required String appointmentIso,     // ISO‑8601 date‑time
    String doctorName = '',
    String location   = '',
    String description = '',
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
        '$homelifeProfilePk/households/$householdPk/medical_appointments/';

    final body = {
      'household'           : householdPk,
      'title'               : title,
      'appointment_datetime': appointmentIso,
      'doctor_name'         : doctorName,
      'location'            : location,
      'description'         : description,
      'homelife_profile'    : homelifeProfilePk,
    };

    final res = await _dio.post(url, data: body);
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> deleteMedicalAppointment({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int medicalAppointmentId,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
        '$homelifeProfilePk/households/$householdPk'
        '/medical_appointments/$medicalAppointmentId';

    final res = await _dio.delete(url);
    return res.statusCode == 204 || res.statusCode == 200;
  }
}