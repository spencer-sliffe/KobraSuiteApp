import 'package:flutter/foundation.dart';
import '../../models/homelife/medication.dart';
import '../../services/homelife/health_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class MedicationProvider extends ChangeNotifier {
  final HealthService _medicationService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<Medication> _medications = [];

  MedicationProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _medicationService = serviceLocator<HealthService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Medication> get medications => _medications;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadMedications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final medications = await
      _medicationService.getMedications(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _medications = medications;
    } catch (e) {
      _errorMessage = 'Error loading medications: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createMedication({
    ///Needs Completed
    required int placholder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _medicationService.createMedication(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk
      );
      if (success) {
        await loadMedications();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating medication: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedication(int medicationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _medicationService.deleteMedication(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        medicationId: medicationId,
      );
      if (success) {
        _medications.removeWhere((a) => a.id == medicationId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting medication: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}