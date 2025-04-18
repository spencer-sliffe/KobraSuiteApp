import 'package:flutter/foundation.dart';
import '../../models/homelife/chore.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class ChoreProvider extends ChangeNotifier {
  final HouseholdService _choreService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<Chore> _chores = [];

  ChoreProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _choreService = serviceLocator<HouseholdService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Chore> get chores => _chores;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadChores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final chores = await _choreService.getChores(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _chores = chores;
    } catch (e) {
      _errorMessage = 'Error loading chores: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createChore({
    required String title,
    required String description,
    required String frequency,
    required int priority,
    String? availableFrom,
    String? availableUntil,
    int? assignedTo,            // adult PK
    int? childAssignedTo,       // child PK
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _choreService.createChore(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        title: title,
        description: description,
        frequency: frequency,
        priority: priority,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
        assignedTo: assignedTo,
        childAssignedTo: childAssignedTo,
      );
      if (success) await loadChores();
      return success;
    } catch (e) {
      _errorMessage = 'Error creating chore: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChore(int choreId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _choreService.deleteChore(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        choreId: choreId,
      );
      if (success) {
        _chores.removeWhere((a) => a.id == choreId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting chore: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}