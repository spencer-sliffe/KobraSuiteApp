import 'package:dio/dio.dart';
import '../../models/homelife/grocery_item.dart';
import '../../models/homelife/grocery_list.dart';
import '../../models/homelife/meal_plan.dart';

class MealService {
  final Dio _dio;
  MealService(this._dio);

  // ------------------------------------------------------------------ helpers
  String _householdBase(
      int userPk, int profilePk, int hlPk, int? hhPk) =>
      '/api/users/$userPk/profile/$profilePk/homelife_profile/'
          '$hlPk/households/$hhPk';

  // ---------------------------------------------------------------- meal plan
  Future<List<MealPlan>> getMealPlans({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/meal_plans/';
    final res = await _dio.get(url);
    if (res.statusCode == 200) {
      final results = (res.data['results'] as List);
      return results.map((e) => MealPlan.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createMealPlan({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String date,            // yyyy‑MM‑dd
    required String mealType,        // BREAKFAST / LUNCH / DINNER …
    required String recipeName,
    String? notes,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/meal_plans/';
    final body = {
      'household': householdPk,
      'date': date,
      'meal_type': mealType,
      'recipe_name': recipeName,
      if (notes != null) 'notes': notes,
    };
    final res = await _dio.post(url, data: body);
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> deleteMealPlan({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int mealPlanId,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/meal_plans/$mealPlanId';
    final res = await _dio.delete(url);
    return res.statusCode == 204 || res.statusCode == 200;
  }

  // ----------------------------------------------------------- grocery lists
  Future<List<GroceryList>> getGroceryLists({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/grocery_lists/';
    final res = await _dio.get(url);
    if (res.statusCode == 200) {
      final results = (res.data['results'] as List);
      return results.map((e) => GroceryList.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createGroceryList({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String name,
    String? description,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/grocery_lists/';
    final body = {
      'household': householdPk,
      'name': name,
      if (description != null) 'description': description,
    };
    final res = await _dio.post(url, data: body);
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> deleteGroceryList({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int groceryListId,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/grocery_lists/$groceryListId';
    final res = await _dio.delete(url);
    return res.statusCode == 204 || res.statusCode == 200;
  }

  // ----------------------------------------------------------- grocery items
  Future<List<GroceryItem>> getGroceryItems({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int groceryListPk,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/grocery_lists/$groceryListPk/grocery_items/';
    final res = await _dio.get(url);
    if (res.statusCode == 200) {
      final results = (res.data['results'] as List);
      return results.map((e) => GroceryItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createGroceryItem({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int groceryListPk,
    required String name,
    String? quantity,
    required bool purchased,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/grocery_lists/$groceryListPk/grocery_items/';
    final body = {
      'household': householdPk,
      'grocery_list': groceryListPk,
      'name': name,
      if (quantity != null) 'quantity': quantity,
      'purchased': purchased,
    };
    final res = await _dio.post(url, data: body);
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> deleteGroceryItem({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int groceryListPk,
    required int groceryItemId,
  }) async {
    final url =
        '${_householdBase(userPk, userProfilePk, homelifeProfilePk, householdPk)}/grocery_lists/$groceryListPk/grocery_items/$groceryItemId';
    final res = await _dio.delete(url);
    return res.statusCode == 204 || res.statusCode == 200;
  }
}