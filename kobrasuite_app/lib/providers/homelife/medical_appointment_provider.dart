import 'package:flutter/foundation.dart';
import '../../models/homelife/medical_appointment.dart';
import '../../services/homelife/health_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class MedicalAppointmentProvider extends ChangeNotifier {
  final HealthService _service = serviceLocator<HealthService>();
  HomeLifeProfileProvider _profile;
  MedicalAppointmentProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider;

  bool _isLoading = false;
  String? _error;
  List<MedicalAppointment> _items = [];

  // getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;
  List<MedicalAppointment> get medicalAppointments => _items;

  // aliases
  int  get _userPk        => _profile.userPk;
  int  get _userProfilePk => _profile.userProfilePk;
  int  get _homeLifePk    => _profile.homeLifeProfilePk;
  int? get _householdPk   => _profile.householdPk;

  void update(HomeLifeProfileProvider newProvider) {
    _profile = newProvider;
    notifyListeners();
  }

  // ───────────────────────── CRUD ─────────────────────────

  Future<void> loadMedicalAppointments() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _items = await _service.getMedicalAppointments(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifePk,
        householdPk: _householdPk,
      );
    } catch (e) {
      _error = 'Unable to load appointments: $e';
    }
    _isLoading = false; notifyListeners();
  }

  Future<bool> createMedicalAppointment({
    required String title,
    required String appointmentIso,   // ISO‑8601 date‑time
    String doctorName = '',
    String location   = '',
    String description = '',
  }) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.createMedicalAppointment(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifePk,
        householdPk: _householdPk,
        title: title,
        appointmentIso: appointmentIso,
        doctorName: doctorName,
        location: location,
        description: description,
      );
      if (ok) await loadMedicalAppointments();
      return ok;
    } catch (e) {
      _error = 'Creation failed: $e';
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> deleteMedicalAppointment(int id) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.deleteMedicalAppointment(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifePk,
        householdPk: _householdPk,
        medicalAppointmentId: id,
      );
      if (ok) _items.removeWhere((a) => a.id == id);
      return ok;
    } catch (e) {
      _error = 'Delete failed: $e';
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}