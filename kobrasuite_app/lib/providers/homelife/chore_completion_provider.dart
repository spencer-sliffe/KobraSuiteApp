import 'package:flutter/foundation.dart';
import '../../models/homelife/chore_completion.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class ChoreCompletionProvider extends ChangeNotifier {
  final HouseholdService _service;
  HomeLifeProfileProvider _profile;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<int, List<ChoreCompletion>> _cache = {};

  ChoreCompletionProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider,
        _service = serviceLocator<HouseholdService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get _userPk => _profile.userPk;
  int get _userProfilePk => _profile.userProfilePk;
  int get _homeLifeProfilePk => _profile.homeLifeProfilePk;
  int? get _householdPk => _profile.householdPk;

  List<ChoreCompletion> completionsForChore(int chorePk) =>
      List.unmodifiable(_cache[chorePk] ?? const []);

  void update(HomeLifeProfileProvider newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  Future<void> loadChoreCompletions(int chorePk) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetched = await _service.getChoreCompletions(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifeProfilePk,
        householdPk: _householdPk,
        chorePk: chorePk,
      );
      _cache[chorePk] = fetched;
    } catch (e) {
      _errorMessage = 'Error loading chore completions: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createChoreCompletion(int chorePk) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _service.createChoreCompletion(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifeProfilePk,
        householdPk: _householdPk,
        chorePk: chorePk,
      );
      if (success) await loadChoreCompletions(chorePk);
      return success;
    } catch (e) {
      _errorMessage = 'Error creating chore completion: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChore(int chorePk, int completionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _service.deleteChoreCompletion(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homeLifeProfilePk,
        householdPk: _householdPk,
        chorePk: chorePk,
        choreCompletionId: completionId,
      );
      if (success) {
        _cache[chorePk]?.removeWhere((c) => c.id == completionId);
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