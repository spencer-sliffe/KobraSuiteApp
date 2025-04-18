import 'package:flutter/foundation.dart';
import '../../models/homelife/medication.dart';
import '../../services/homelife/health_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class MedicationProvider extends ChangeNotifier {
  final HealthService _service = serviceLocator<HealthService>();
  HomeLifeProfileProvider _profile;
  MedicationProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider;

  bool _isLoading = false;
  String? _error;
  List<Medication> _items = [];

  // ───────── getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;
  List<Medication> get medications => _items;

  // ───────── handy aliases
  int  get _userPk          => _profile.userPk;
  int  get _userProfilePk   => _profile.userProfilePk;
  int  get _homeLifePk      => _profile.homeLifeProfilePk;
  int? get _householdPk     => _profile.householdPk;

  void update(HomeLifeProfileProvider newProvider) {
    _profile = newProvider;
    notifyListeners();
  }

  // ───────────────────────── CRUD ─────────────────────────

  Future<void> loadMedications() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _items = await _service.getMedications(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifePk,
        householdPk: _householdPk,
      );
    } catch (e) {
      _error = 'Unable to load medications: $e';
    }
    _isLoading = false; notifyListeners();
  }

  Future<bool> createMedication({
    required String name,
    required String dosage,
    required String frequency,
    String? nextDoseIso,
    String notes = '',
  }) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.createMedication(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifePk,
        householdPk: _householdPk,
        name: name,
        dosage: dosage,
        frequency: frequency,
        nextDoseIso: nextDoseIso,
        notes: notes,
      );
      if (ok) await loadMedications();
      return ok;
    } catch (e) {
      _error = 'Medication creation failed: $e';
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> deleteMedication(int id) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.deleteMedication(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifePk,
        householdPk: _householdPk,
        medicationId: id,
      );
      if (ok) _items.removeWhere((m) => m.id == id);
      return ok;
    } catch (e) {
      _error = 'Delete failed: $e';
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}