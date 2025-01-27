import 'package:flutter/foundation.dart';
import '../../models/work/work_profile.dart';
import '../../services/general/work_profile_service.dart';
import '../../services/service_locator.dart';

class WorkProfileProvider extends ChangeNotifier {
  final WorkProfileService _workProfileService;
  int _userPk;
  int _workProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  WorkProfile? _profile;

  WorkProfileProvider({
    required int userPk,
    required int workProfilePk,
  })  : _userPk = userPk,
        _workProfilePk = workProfilePk,
        _workProfileService = serviceLocator<WorkProfileService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  WorkProfile? get profile => _profile;
  int get userPk => _userPk;
  int get workProfilePk => _workProfilePk;

  void update(int newUserPk, int newWorkProfilePk) {
    _userPk = newUserPk;
    _workProfilePk = newWorkProfilePk;
    notifyListeners();
  }

  Future<bool> loadWorkProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetchedProfile = await _workProfileService.getWorkProfile(
        userPk: _userPk,
        workProfilePk: _workProfilePk,
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

  Future<bool> updateWorkProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final updatedProfile = await _workProfileService.updateWorkProfile(
        userPk: _userPk,
        workProfilePk: _workProfilePk,
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