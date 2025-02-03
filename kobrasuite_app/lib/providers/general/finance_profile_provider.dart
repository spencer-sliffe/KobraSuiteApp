import 'package:flutter/foundation.dart';
import '../../models/finance/finance_profile.dart';
import '../../services/general/finance_profile_service.dart';
import '../../services/service_locator.dart';

class FinanceProfileProvider extends ChangeNotifier {
  final FinanceProfileService _financeProfileService;
  int _userPk;
  int _financeProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  FinanceProfile? _profile;

  FinanceProfileProvider({
    required int userPk,
    required int financeProfilePk,
  })  : _userPk = userPk,
        _financeProfilePk = financeProfilePk,
        _financeProfileService = serviceLocator<FinanceProfileService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  FinanceProfile? get profile => _profile;
  int get userPk => _userPk;
  int get financeProfilePk => _financeProfilePk;

  void update(int newUserPk, int newFinanceProfilePk) {
    _userPk = newUserPk;
    _financeProfilePk = newFinanceProfilePk;
    notifyListeners();
  }

  Future<bool> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetchedProfile = await _financeProfileService.getFinanceProfile(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
      );
      if (fetchedProfile != null) {
        _profile = fetchedProfile;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Finance Profile not found.';
    } catch (e) {
      _errorMessage = 'Error loading Finance Profile: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateFinanceProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final updatedProfile = await _financeProfileService.updateFinanceProfile(
        userPk: _userPk,
        financeProfilePk: _financeProfilePk,
        updatedData: updatedData,
      );
      if (updatedProfile != null) {
        _profile = updatedProfile;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Failed to update Finance Profile.';
    } catch (e) {
      _errorMessage = 'Error updating Finance Profile: $e';
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