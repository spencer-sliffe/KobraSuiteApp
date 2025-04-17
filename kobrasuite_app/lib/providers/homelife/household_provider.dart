import 'package:flutter/foundation.dart';
import '../../models/homelife/household.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class HouseholdProvider extends ChangeNotifier {
  final HouseholdService _householdService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  Household? _household;

  HouseholdProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _householdService = serviceLocator<HouseholdService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Household? get household => _household;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadHousehold() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final household = await _householdService.getHousehold(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
      );
      _household = household;
    } catch (e) {
      _errorMessage = 'Error loading household: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createHousehold({
    required String householdName,
    required String householdType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _householdService.createHousehold(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdName: householdName,
        householdType: householdType,
      );
      if (success) {
        await loadHousehold();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating household: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteHousehold(int householdId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _householdService.deleteHousehold(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdId: householdId,
      );
      if (success) {
        _household = null;
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting household: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
