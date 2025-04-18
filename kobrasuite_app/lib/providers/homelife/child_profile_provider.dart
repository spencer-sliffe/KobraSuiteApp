import 'package:flutter/foundation.dart';
import '../../models/homelife/child_profile.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class ChildProfileProvider extends ChangeNotifier {
  final HouseholdService _childProfileService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<ChildProfile> _childProfiles = [];

  ChildProfileProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _childProfileService = serviceLocator<HouseholdService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChildProfile> get childProfiles => _childProfiles;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadChildProfiles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final childProfiles = await _childProfileService.getChildProfiles(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _childProfiles = childProfiles;
    } catch (e) {
      _errorMessage = 'Error loading child profile: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createChildProfile({
    ///Needs Completed
    required String name,
    required String dateOfBirth,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _childProfileService.createChildProfile(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk,
          name: name,
          dateOfBirth: dateOfBirth,
      );
      if (success) {
        await loadChildProfiles();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating child profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChildProfile(int childProfileId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _childProfileService.deleteChildProfile(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        childProfileId: childProfileId,
      );
      if (success) {
        _childProfiles.removeWhere((a) => a.id == childProfileId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting child profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}