import 'package:flutter/foundation.dart';
import '../../models/school/school_profile.dart';
import '../../services/general/school_profile_service.dart';
import '../../services/service_locator.dart';

class SchoolProfileProvider extends ChangeNotifier {
  final SchoolProfileService _schoolProfileService;
  int _userPk;
  int _schoolProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  SchoolProfile? _profile;

  SchoolProfileProvider({
    required int userPk,
    required int schoolProfilePk,
  })  : _userPk = userPk,
        _schoolProfilePk = schoolProfilePk,
        _schoolProfileService = serviceLocator<SchoolProfileService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  SchoolProfile? get profile => _profile;
  int get userPk => _userPk;
  int get schoolProfilePk => _schoolProfilePk;

  void update(int newUserPk, int newSchoolProfilePk) {
    _userPk = newUserPk;
    _schoolProfilePk = newSchoolProfilePk;
    notifyListeners();
  }

  Future<bool> loadSchoolProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetchedProfile = await _schoolProfileService.getSchoolProfile(
        userPk: _userPk,
        schoolProfilePk: _schoolProfilePk,
      );
      if (fetchedProfile != null) {
        _profile = fetchedProfile;
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
        schoolProfilePk: _schoolProfilePk,
        updatedData: updatedData,
      );
      if (updatedProfile != null) {
        _profile = updatedProfile;
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
    _profile = null;
    _errorMessage = '';
    notifyListeners();
  }
}