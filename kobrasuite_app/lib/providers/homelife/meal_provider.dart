import 'package:flutter/foundation.dart';
import '../../models/homelife/meal_plan.dart';
import '../../services/homelife/meal_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class MealProvider extends ChangeNotifier {
  final MealService _service = serviceLocator<MealService>();
  HomeLifeProfileProvider _profile;

  MealProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider;

  // -------------------------------------------------------------- state
  bool _loading = false;
  String? _error;
  List<MealPlan> _meals = [];

  bool  get isLoading     => _loading;
  String? get errorMessage => _error;
  List<MealPlan> get meals => _meals;

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
  Future<void> loadMeals() async {
    _loading = true; _error = null; notifyListeners();
    try {
      _meals = await _service.getMealPlans(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
      );
    } catch (e) {
      _error = 'Error loading meals: $e';
    }
    _loading = false; notifyListeners();
  }

  Future<bool> createMeal({
    required String date,          // yyyy‑MM‑dd
    required String mealType,      // BREAKFAST / LUNCH / DINNER …
    required String recipeName,
    String? notes,
  }) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.createMealPlan(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
        date: date,
        mealType: mealType,
        recipeName: recipeName,
        notes: notes,
      );
      if (ok) await loadMeals();
      return ok;
    } catch (e) {
      _error = 'Error creating meal plan: $e';
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<bool> deleteMeal(int id) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final ok = await _service.deleteMealPlan(
        userPk: _userPk,
        userProfilePk: _profilePk,
        homelifeProfilePk: _hlPk,
        householdPk: _hhPk,
        mealPlanId: id,
      );
      if (ok) _meals.removeWhere((m) => m.id == id);
      return ok;
    } catch (e) {
      _error = 'Error deleting meal plan: $e';
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }
}