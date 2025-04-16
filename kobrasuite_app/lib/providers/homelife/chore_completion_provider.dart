import 'package:flutter/foundation.dart';
import '../../models/homelife/chore_completion.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class ChoreCompletionProvider extends ChangeNotifier {
  final HouseholdService _choreCompletionService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<ChoreCompletion> _choreCompletions = [];

  ChoreCompletionProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _choreCompletionService = serviceLocator<HouseholdService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChoreCompletion> get choreCompletions => _choreCompletions;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadChoreCompletions(int chorePk) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final choreCompletions = await _choreCompletionService.getChoreCompletions(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        chorePk: chorePk,
      );
      _choreCompletions = choreCompletions;
    } catch (e) {
      _errorMessage = 'Error loading chore completions: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createChoreCompletion(
    ///Needs Completed
    int chorePk
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _choreCompletionService.createChoreCompletion(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk,
          chorePk: chorePk,
      );
      if (success) {
        await loadChoreCompletions(chorePk);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating chore completion: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChore(int chorePk, int choreCompletionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _choreCompletionService.deleteChoreCompletion(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        chorePk: chorePk,
        choreCompletionId: choreCompletionId,
      );
      if (success) {
        _choreCompletions.removeWhere((a) => a.id == choreCompletionId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting chore completion: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}