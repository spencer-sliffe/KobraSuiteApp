import 'package:flutter/foundation.dart';
import '../../models/general/user_profile.dart';
import '../../services/general/user_profile_service.dart';
import '../../services/service_locator.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileService _userProfileService;
  int _userPk;
  int _userProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  UserProfile? _profile;

  UserProfileProvider({
    required int userPk,
    required int userProfilePk,
  })  : _userPk = userPk,
        _userProfilePk = userProfilePk,
        _userProfileService = serviceLocator<UserProfileService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;
  int get userPk => _userPk;
  int get userProfilePk => _userProfilePk;

  void update(int newUserPk, int newUserProfilePk) {
    _userPk = newUserPk;
    _userProfilePk = newUserProfilePk;
    notifyListeners();
  }

  Future<bool> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetchedProfile = await _userProfileService.getUserProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
      );
      if (fetchedProfile != null) {
        _profile = fetchedProfile;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'User Profile not found.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error loading User Profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final updatedProfile = await _userProfileService.updateUserProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        updatedData: updatedData,
      );
      if (updatedProfile != null) {
        _profile = updatedProfile;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Failed to update User Profile.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error updating User Profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _profile = null;
    _errorMessage = '';
    notifyListeners();
  }
}