import 'package:flutter/foundation.dart';
import '../../models/finance/finance_profile.dart';
import '../../services/general/finance_profile_service.dart';
import '../../services/general/user_profile_service.dart';
import '../../services/service_locator.dart';

class FinanceProfileProvider extends ChangeNotifier {
  final FinanceProfileService _financeProfileService;

  int _userPk;
  int _userProfilePk;
  int _financeProfilePk;
  bool _isLoading = false;
  String _errorMessage = '';
  FinanceProfile? _financeProfile;

  FinanceProfileProvider({
    required int userPk,
    required int userProfilePk,
    required int financeProfilePk,
  })  : _userPk = userPk,
        _userProfilePk = userProfilePk,
        _financeProfilePk = financeProfilePk,
        _financeProfileService = serviceLocator<FinanceProfileService>();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  FinanceProfile? get financeProfile => _financeProfile;
  int get userPk => _userPk;
  int get userProfilePk => _userProfilePk;
  int get financeProfilePk => _financeProfilePk;

  void update(int newUserPk, int newUserProfilePk, int newFinanceProfilePk) {
    _userPk = newUserPk;
    _userProfilePk = newUserProfilePk;
    _financeProfilePk = newFinanceProfilePk;
    notifyListeners();
  }

  Future<bool> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final fetchedFinanceProfile = await _financeProfileService.getFinanceProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
      );
      if (fetchedFinanceProfile != null) {
        _financeProfile = fetchedFinanceProfile;
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
      final updatedFinanceProfile = await _financeProfileService.updateFinanceProfile(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        financeProfilePk: _financeProfilePk,
        updatedData: updatedData,
      );
      if (updatedFinanceProfile != null) {
        _financeProfile = updatedFinanceProfile;
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
    _financeProfile = null;
    _errorMessage = '';
    notifyListeners();
  }
}