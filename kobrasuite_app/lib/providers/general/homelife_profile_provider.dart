import 'package:flutter/foundation.dart';
import '../../models/homelife/homelife_profile.dart';
import '../../services/general/homelife_profile_service.dart';
import '../../services/service_locator.dart';

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

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  HomeLifeProfile? get homeLifeProfile => _homeLifeProfile;
  int get userPk => _userPk;
  int get userProfilePk => _userProfilePk;
  int get homeLifeProfilePk => _homeLifeProfilePk;

  void update(int newUserPk, int newUserProfilePk, int newHomeLifeProfilePk) {
    _userPk = newUserPk;
    _userProfilePk = newUserProfilePk;
    _homeLifeProfilePk = newHomeLifeProfilePk;
    notifyListeners();
  }

  Future<bool> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetchedHomeLifeProfile = await _homeLifeProfileService.getHomeLifeProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homeLifeProfilePk: _homeLifeProfilePk,
      );
      if (fetchedHomeLifeProfile != null) {
        _homeLifeProfile = fetchedHomeLifeProfile;
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

  Future<bool> updateHomeLifeProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final updatedHomeLifeProfile = await _homeLifeProfileService.updateHomeLifeProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homeLifeProfilePk: _homeLifeProfilePk,
        updatedData: updatedData,
      );
      if (updatedHomeLifeProfile != null) {
        _homeLifeProfile = updatedHomeLifeProfile;
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