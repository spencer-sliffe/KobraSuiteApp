import 'package:flutter/foundation.dart';
import '../../models/homelife/household.dart';
import '../../models/homelife/pet.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class PetProvider extends ChangeNotifier {
  final HouseholdService _petService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<Pet> _pets = [];

  PetProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _petService = serviceLocator<HouseholdService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Pet> get pets => _pets;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final pets = await _petService.getPets(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _pets =pets;
    } catch (e) {
      _errorMessage = 'Error loading pets: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPet({
    required String petName,
    required String petType,
    String foodInstructions = '',
    String waterInstructions = '',
    String medicationInstructions = '',
    required String foodFrequency,
    required String waterFrequency,
    required String medicationFrequency,
    List<String>? foodTimes,
    List<String>? waterTimes,
    List<String>? medicationTimes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _petService.createPet(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        petName: petName,
        petType: petType,
        foodInstructions: foodInstructions,
        waterInstructions: waterInstructions,
        medicationInstructions: medicationInstructions,
        foodFrequency: foodFrequency,
        waterFrequency: waterFrequency,
        medicationFrequency: medicationFrequency,
        foodTimes: foodTimes,
        waterTimes: waterTimes,
        medicationTimes: medicationTimes,
      );
      if (success) await loadPets();
      return success;
    } catch (e) {
      _errorMessage = 'Error creating pet: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePet(int petId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _petService.deletePet(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        petId: petId,
      );
      if (success) {
        _pets.removeWhere((a) => a.id == petId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting pet: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}