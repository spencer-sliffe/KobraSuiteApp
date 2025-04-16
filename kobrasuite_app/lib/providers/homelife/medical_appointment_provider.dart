import 'package:flutter/foundation.dart';
import '../../models/homelife/medical_appointment.dart';
import '../../services/homelife/health_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class MedicalAppointmentProvider extends ChangeNotifier {
  final HealthService _medicalAppointmentService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<MedicalAppointment> _medicalAppointments = [];

  MedicalAppointmentProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _medicalAppointmentService = serviceLocator<HealthService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MedicalAppointment> get medicalAppointments => _medicalAppointments;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadMedicalAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final medicalAppointments = await
      _medicalAppointmentService.getMedicalAppointments(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _medicalAppointments = medicalAppointments;
    } catch (e) {
      _errorMessage = 'Error loading medical appointments: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createMedicalAppointment({
    ///Needs Completed
    required int placholder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _medicalAppointmentService.createMedicalAppointment(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk
      );
      if (success) {
        await loadMedicalAppointments();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating medical appointment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedicalAppointment(int medicalAppointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _medicalAppointmentService.deleteMedicalAppointment(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        medicalAppointmentId: medicalAppointmentId,
      );
      if (success) {
        _medicalAppointments.removeWhere((a) => a.id == medicalAppointmentId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting medical appointment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}