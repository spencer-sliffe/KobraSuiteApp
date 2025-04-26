import 'package:flutter/foundation.dart';
import '../../models/homelife/chore.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class ChoreProvider extends ChangeNotifier {
  final HouseholdService _choreService;
  HomeLifeProfileProvider _profile;
  bool _isLoading = false;
  String? _errorMessage;
  List<Chore> _chores = [];

  ChoreProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider,
        _choreService = serviceLocator<HouseholdService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Chore> get chores => List.unmodifiable(_chores);

  int get _userPk => _profile.userPk;
  int get _userProfilePk => _profile.userProfilePk;
  int get _homeLifeProfilePk => _profile.homeLifeProfilePk;
  int? get _householdPk => _profile.householdPk;

  void update(HomeLifeProfileProvider newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  Future<void> loadChores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _chores = await _choreService.getChores(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifeProfilePk,
        householdPk: _householdPk,
      );
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
    int? assignedTo,
    int? childAssignedTo,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final ok = await _choreService.createChore(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifeProfilePk,
        householdPk: _householdPk,
        title: title,
        description: description,
        frequency: frequency,
        priority: priority,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
        assignedTo: assignedTo,
        childAssignedTo: childAssignedTo,
      );
      if (ok) await loadChores();
      return ok;
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
      final ok = await _choreService.deleteChore(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifeProfilePk,
        householdPk: _householdPk,
        choreId: choreId,
      );
      if (ok) _chores.removeWhere((c) => c.id == choreId);
      return ok;
    } catch (e) {
      _errorMessage = 'Error deleting chore: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}