import 'package:dio/dio.dart';
import '../../models/homelife/grocery_item.dart';
import '../../models/homelife/grocery_list.dart';
import '../../models/homelife/meal_plan.dart';

class MealService {
  final Dio _dio;
  MealService(this._dio);

  Future<List<MealPlan>> getMealPlans({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/meal_plans/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => MealPlan.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createMealPlan({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/meal_plans/';
      final body = {
        'homelife_profile': homelifeProfilePk,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteMealPlan({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int mealPlanId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/meal_plans/$mealPlanId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GroceryList>> getGroceryLists({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/grocery_lists/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => GroceryList.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createGroceryList({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/grocery_lists/';
      final body = {
        'homelife_profile': homelifeProfilePk,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteGroceryList({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int groceryListId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/grocery_lists/$groceryListId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GroceryItem>> getGroceryItems({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int groceryListPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/grocery_lists/'
          '$groceryListPk/grocery_items/';

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => GroceryItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createGroceryItem({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int groceryListPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/grocery_lists/'
          '$groceryListPk/grocery_items/';
      final body = {
        'homelife_profile': homelifeProfilePk,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteGroceryItem({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int groceryListPk,
    required int groceryItemId
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/grocery_lists/'
          '$groceryListPk/grocery_items/$groceryItemId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}