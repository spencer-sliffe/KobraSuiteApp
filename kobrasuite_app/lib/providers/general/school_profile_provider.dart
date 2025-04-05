import 'package:flutter/foundation.dart';
import '../../models/school/school_profile.dart';
import '../../services/general/school_profile_service.dart';
import '../../services/service_locator.dart';

class SchoolProfileProvider extends ChangeNotifier {
  final SchoolProfileService _schoolProfileService;
  int _userPk;
  int _userProfilePk;
  int _schoolProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  SchoolProfile? _schoolProfile;

  SchoolProfileProvider({
    required int userPk,
    required int userProfilePk,
    required int schoolProfilePk,
  })  : _userPk = userPk,
        _userProfilePk = userProfilePk,
        _schoolProfilePk = schoolProfilePk,
        _schoolProfileService = serviceLocator<SchoolProfileService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  SchoolProfile? get schoolProfile => _schoolProfile;
  int get userPk => _userPk;
  int get userProfilePk => _userProfilePk;
  int get schoolProfilePk => _schoolProfilePk;

  void update(int newUserPk, int newUserProfilePk, int newSchoolProfilePk) {
    _userPk = newUserPk;
    _userProfilePk = newUserProfilePk;
    _schoolProfilePk = newSchoolProfilePk;
    notifyListeners();
  }

  Future<bool> loadSchoolProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetchedSchoolProfile = await _schoolProfileService.getSchoolProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        schoolProfilePk: _schoolProfilePk,
      );
      if (fetchedSchoolProfile != null) {
        _schoolProfile = fetchedSchoolProfile;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'School Profile not found.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error loading School Profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchoolProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final updatedProfile = await _schoolProfileService.updateSchoolProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        schoolProfilePk: _schoolProfilePk,
        updatedData: updatedData,
      );
      if (updatedProfile != null) {
        _schoolProfile = updatedProfile;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Failed to update School Profile.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error updating School Profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _schoolProfile = null;
    _errorMessage = '';
    notifyListeners();
  }
}