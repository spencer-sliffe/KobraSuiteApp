import 'package:flutter/foundation.dart';
import '../../models/homelife/meal_plan.dart';
import '../../services/homelife/meal_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class MealProvider extends ChangeNotifier {
  final MealService _mealService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<MealPlan> _meals = [];

  MealProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _mealService = serviceLocator<MealService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MealPlan> get meals => _meals;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadMeals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final meals = await _mealService.getMealPlans(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _meals = meals;
    } catch (e) {
      _errorMessage = 'Error loading meals: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createMeal({
    ///Needs Completed
    required int placholder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _mealService.createMealPlan(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk
      );
      if (success) {
        await loadMeals();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating meal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMeal(int mealId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _mealService.deleteMealPlan(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        mealPlanId: mealId,
      );
      if (success) {
        _meals.removeWhere((a) => a.id == mealId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting meal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}