import 'package:flutter/foundation.dart';
import '../../models/homelife/grocery_item.dart';
import '../../services/homelife/meal_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class GroceryItemProvider extends ChangeNotifier {
  final MealService _service = serviceLocator<MealService>();
  HomeLifeProfileProvider _profile;

  GroceryItemProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider;

  // ---------------------------------------------------------------- state
  bool _loading = false;
  String? _error;
  List<GroceryItem> _items = [];

  bool  get isLoading     => _loading;
  String? get errorMessage => _error;
  List<GroceryItem> get groceryItems => _items;

  // ---------------------------------------------------------------- helpers
  int  get _userPk        => _profile.userPk;
  int  get _profilePk     => _profile.userProfilePk;
  int  get _hlPk          => _profile.homeLifeProfilePk;
  int? get _hhPk          => _profile.householdPk;

  void update(HomeLifeProfileProvider p) {
    _profile = p;
    notifyListeners();
  }

  // ---------------------------------------------------------------- actions
  Future<void> loadGroceryItems(int listId) async {
    _loading = true; _error = null; notifyListeners();
    try {
      _items = await _service.getGroceryItems(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
        groceryListPk: listId,
      );
    } catch (e) {
      _error = 'Error loading grocery items: $e';
    }
    _loading = false; notifyListeners();
  }

  Future<bool> createGroceryItem({
    required int groceryListId,
    required String name,
    String? quantity,
    required bool purchased,
  }) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.createGroceryItem(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
        groceryListPk: groceryListId,
        name: name,
        quantity: quantity,
        purchased: purchased,
      );
      if (ok) await loadGroceryItems(groceryListId);
      return ok;
    } catch (e) {
      _error = 'Error creating grocery item: $e';
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<bool> deleteGroceryItem({
    required int groceryListId,
    required int groceryItemId,
  }) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.deleteGroceryItem(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
        groceryListPk: groceryListId,
        groceryItemId: groceryItemId,
      );
      if (ok) _items.removeWhere((i) => i.id == groceryItemId);
      return ok;
    } catch (e) {
      _error = 'Error deleting grocery item: $e';
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }
}