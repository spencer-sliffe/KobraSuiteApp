import 'package:flutter/foundation.dart';
import '../../models/homelife/grocery_list.dart';
import '../../services/homelife/meal_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class GroceryListProvider extends ChangeNotifier {
  final MealService _groceryListService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<GroceryList> _groceryLists = [];

  GroceryListProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _groceryListService = serviceLocator<MealService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<GroceryList> get groceryLists => _groceryLists;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadGroceryLists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final groceryLists = await _groceryListService.getGroceryLists(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _groceryLists = groceryLists;
    } catch (e) {
      _errorMessage = 'Error loading grocery lists: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createGroceryList({
    ///Needs Completed
    required int placholder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _groceryListService.createGroceryList(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk
      );
      if (success) {
        await loadGroceryLists();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating grocery list: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGroceryList(int groceryListId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _groceryListService.deleteGroceryList(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        groceryListId: groceryListId,
      );
      if (success) {
        _groceryLists.removeWhere((a) => a.id == groceryListId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting grocery list: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}