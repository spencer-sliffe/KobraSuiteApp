import 'package:flutter/foundation.dart';
import '../../models/homelife/homelife_profile.dart';
import '../../services/general/homelife_profile_service.dart';
import '../../services/service_locator.dart';

class HomeLifeProfileProvider extends ChangeNotifier {
  final HomeLifeProfileService _homeLifeProfileService;
  int _userPk;
  int _homeLifeProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  HomeLifeProfile? _profile;

  HomeLifeProfileProvider({
    required int userPk,
    required int homeLifeProfilePk,
  })  : _userPk = userPk,
        _homeLifeProfilePk = homeLifeProfilePk,
        _homeLifeProfileService = serviceLocator<HomeLifeProfileService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  HomeLifeProfile? get profile => _profile;
  int get userPk => _userPk;
  int get homeLifeProfilePk => _homeLifeProfilePk;

  void update(int newUserPk, int newHomeLifeProfilePk) {
    _userPk = newUserPk;
    _homeLifeProfilePk = newHomeLifeProfilePk;
    notifyListeners();
  }

  Future<bool> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetchedProfile = await _homeLifeProfileService.getHomeLifeProfile(
        userPk: _userPk,
        homeLifeProfilePk: _homeLifeProfilePk,
      );
      if (fetchedProfile != null) {
        _profile = fetchedProfile;
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
      final updatedProfile = await _homeLifeProfileService.updateHomeLifeProfile(
        userPk: _userPk,
        homeLifeProfilePk: _homeLifeProfilePk,
        updatedData: updatedData,
      );
      if (updatedProfile != null) {
        _profile = updatedProfile;
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
    _profile = null;
    _errorMessage = '';
    notifyListeners();
  }
}