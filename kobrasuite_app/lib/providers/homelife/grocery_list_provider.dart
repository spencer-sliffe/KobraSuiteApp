import 'package:flutter/foundation.dart';
import '../../models/homelife/grocery_list.dart';
import '../../services/homelife/meal_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class GroceryListProvider extends ChangeNotifier {
  final MealService _service = serviceLocator<MealService>();
  HomeLifeProfileProvider _profile;

  GroceryListProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider;

  // -------------------------------------------------------------- state
  bool _loading = false;
  String? _error;
  List<GroceryList> _lists = [];

  bool  get isLoading     => _loading;
  String? get errorMessage => _error;
  List<GroceryList> get groceryLists => _lists;

  // -------------------------------------------------------------- helpers
  int  get _userPk        => _profile.userPk;
  int  get _profilePk     => _profile.userProfilePk;
  int  get _hlPk          => _profile.homeLifeProfilePk;
  int? get _hhPk          => _profile.householdPk;

  void update(HomeLifeProfileProvider p) {
    _profile = p;
    notifyListeners();
  }

  // -------------------------------------------------------------- actions
  Future<void> loadGroceryLists() async {
    _loading = true; _error = null; notifyListeners();
    try {
      _lists = await _service.getGroceryLists(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
      );
    } catch (e) {
      _error = 'Error loading grocery lists: $e';
    }
    _loading = false; notifyListeners();
  }

  Future<bool> createGroceryList({
    required String name,
    String? description,
    required String runDatetimeIso,
  }) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.createGroceryList(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
        name: name,
        description: description,
        runDatetimeIso: runDatetimeIso,
      );
      if (ok) await loadGroceryLists();
      return ok;
    } catch (e) {
      _error = 'Error creating grocery list: $e';
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<bool> deleteGroceryList(int id) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.deleteGroceryList(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
        groceryListId: id,
      );
      if (ok) _lists.removeWhere((l) => l.id == id);
      return ok;
    } catch (e) {
      _error = 'Error deleting grocery list: $e';
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }
}