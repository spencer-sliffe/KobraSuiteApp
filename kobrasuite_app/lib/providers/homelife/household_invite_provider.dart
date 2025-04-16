import 'package:flutter/foundation.dart';
import '../../models/homelife/household_invite.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class HouseholdInviteProvider extends ChangeNotifier {
  final HouseholdService _householdInviteService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<HouseholdInvite> _householdInvites = [];

  HouseholdInviteProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _householdInviteService = serviceLocator<HouseholdService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<HouseholdInvite> get householdInvites => _householdInvites;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadHouseholdInvites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final householdInvites = await _householdInviteService.getHouseholdInvites(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
      );
      _householdInvites = householdInvites;
    } catch (e) {
      _errorMessage = 'Error loading invites: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createHouseholdInvite({
    ///Needs Completed
    required int placholder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _householdInviteService.createHouseholdInvite(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk
      );
      if (success) {
        await loadHouseholdInvites();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating household invites: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteHouseholdInvite(int householdInviteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _householdInviteService.deleteHouseholdInvite(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        householdInviteId: householdInviteId,
      );
      if (success) {
        _householdInvites.removeWhere((a) => a.id == householdInviteId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting household invite: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}