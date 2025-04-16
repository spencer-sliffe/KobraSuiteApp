import 'package:flutter/foundation.dart';
import '../../models/homelife/grocery_item.dart';
import '../../services/homelife/meal_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class GroceryItemProvider extends ChangeNotifier {
  final MealService _groceryItemService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<GroceryItem> _groceryItems = [];

  GroceryItemProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _groceryItemService = serviceLocator<MealService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<GroceryItem> get groceryItems => _groceryItems;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadGroceryItems(int groceryListId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final groceryItems = await _groceryItemService.getGroceryItems(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        groceryListPk: groceryListId,
      );
      _groceryItems = groceryItems;
    } catch (e) {
      _errorMessage = 'Error loading grocery items: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createGroceryList(
    ///Needs Completed
    int groceryListId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _groceryItemService.createGroceryItem(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk,
          groceryListPk: groceryListId
      );
      if (success) {
        await loadGroceryItems(groceryListId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating grocery item: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGroceryItem(int groceryListId, int groceryItemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _groceryItemService.deleteGroceryItem(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        groceryListPk: groceryListId,
        groceryItemId: groceryItemId
      );
      if (success) {
        _groceryItems.removeWhere((a) => a.id == groceryItemId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting grocery item: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}