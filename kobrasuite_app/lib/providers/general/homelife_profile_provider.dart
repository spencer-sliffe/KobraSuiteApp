import 'package:flutter/foundation.dart';
import '../../models/homelife/homelife_profile.dart';
import '../../services/general/homelife_profile_service.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../../models/homelife/household.dart';

class HomeLifeProfileProvider extends ChangeNotifier {
  final HomeLifeProfileService _homeLifeProfileService;
  final HouseholdService _householdService;
  int _userPk;
  int _userProfilePk;
  int _homeLifeProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  HomeLifeProfile? _homeLifeProfile;
  int? _householdPk;

  HomeLifeProfileProvider({
    required int userPk,
    required int userProfilePk,
    required int homeLifeProfilePk,
  })  : _userPk = userPk,
        _userProfilePk = userProfilePk,
        _homeLifeProfilePk = homeLifeProfilePk,
        _homeLifeProfileService = serviceLocator<HomeLifeProfileService>(),
        _householdService = serviceLocator<HouseholdService>();


  // Basic getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  HomeLifeProfile? get homeLifeProfile => _homeLifeProfile;

  // Convenient getters for household
  int? get householdPk => _householdPk;

  // IDs
  int get userPk => _userPk;
  int get userProfilePk => _userProfilePk;
  int get homeLifeProfilePk => _homeLifeProfilePk;

  // Update method for ChangeNotifierProxyProvider in main.dart
  void update(int newUserPk, int newUserProfilePk, int newHomeLifeProfilePk) {
    _userPk = newUserPk;
    _userProfilePk = newUserProfilePk;
    _homeLifeProfilePk = newHomeLifeProfilePk;
    notifyListeners();

    if (_userPk > 0 && _userProfilePk > 0 && _homeLifeProfilePk > 0) {
      _loadHouseholdPk();
    }
  }

  /// Loads the entire HomeLifeProfile from the backend.
  /// If successful, it sets [_homeLifeProfile], which includes household data.
  Future<void> _loadHouseholdPk() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final household = await _householdService.getHousehold(
        userPk:            _userPk,
        userProfilePk:     _userProfilePk,
        homelifeProfilePk: _homeLifeProfilePk,
      );
      _householdPk = household?.id;
    } catch (e) {
      _errorMessage = 'Error loading household PK: $e';
      _householdPk = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// If you ever need to clear it (e.g. on logout)
  void clear() {
    _householdPk = null;
    _errorMessage = '';
    notifyListeners();
  }
  
  /// Updates the HomeLifeProfile (including any household-related fields
  /// if your backend supports that) and refreshes [_homeLifeProfile].
  Future<bool> updateHomeLifeProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final updated = await _homeLifeProfileService.updateHomeLifeProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homeLifeProfilePk: _homeLifeProfilePk,
        updatedData: updatedData,
      );
      if (updated != null) {
        _homeLifeProfile = updated;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Failed to update HomeLife Profile.';
    } catch (e) {
      _errorMessage = 'Error updating HomeLife Profile: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}