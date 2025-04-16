import 'package:flutter/foundation.dart';
import '../../models/homelife/homelife_profile.dart';
import '../../services/general/homelife_profile_service.dart';
import '../../services/service_locator.dart';
import '../../models/homelife/household.dart';

class HomeLifeProfileProvider extends ChangeNotifier {
  final HomeLifeProfileService _homeLifeProfileService;
  int _userPk;
  int _userProfilePk;
  int _homeLifeProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  HomeLifeProfile? _homeLifeProfile;

  HomeLifeProfileProvider({
    required int userPk,
    required int userProfilePk,
    required int homeLifeProfilePk,
  })  : _userPk = userPk,
        _userProfilePk = userProfilePk,
        _homeLifeProfilePk = homeLifeProfilePk,
        _homeLifeProfileService = serviceLocator<HomeLifeProfileService>();

  // Basic getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  HomeLifeProfile? get homeLifeProfile => _homeLifeProfile;

  // Convenient getters for household
  Household? get householdDetail => _homeLifeProfile?.householdDetail;
  int? get householdPk => householdDetail?.id;

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
  }

  /// Loads the entire HomeLifeProfile from the backend.
  /// If successful, it sets [_homeLifeProfile], which includes household data.
  Future<bool> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetched = await _homeLifeProfileService.getHomeLifeProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homeLifeProfilePk: _homeLifeProfilePk,
      );
      if (fetched != null) {
        _homeLifeProfile = fetched;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'HomeLife Profile not found.';
    } catch (e) {
      _errorMessage = 'Error loading HomeLife Profile: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
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

  void clear() {
    _homeLifeProfile = null;
    _errorMessage = '';
    notifyListeners();
  }
}