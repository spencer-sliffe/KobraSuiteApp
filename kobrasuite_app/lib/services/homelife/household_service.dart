import 'package:dio/dio.dart';
import '../../models/homelife/child_profile.dart';
import '../../models/homelife/chore.dart';
import '../../models/homelife/chore_completion.dart';
import '../../models/homelife/homelife_profile.dart';
import '../../models/homelife/household.dart';
import '../../models/homelife/household_invite.dart';
import '../../models/homelife/pet.dart';

class HouseholdService {
  final Dio _dio;

  HouseholdService(this._dio);

  Future<Household?> getHousehold({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        if (results.isNotEmpty) {
          return Household.fromJson(results[0]);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createHousehold({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required String householdName,
    required String householdType,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/';
      final body = {
        'name': householdName,
        'household_type': householdType,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteHousehold({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HouseholdInvite>> getHouseholdInvites({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/household_invites/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => HouseholdInvite.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createHouseholdInvite({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String code,
    required int inviter,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/household_invites/';
      final body = {
        'code': code,
        'inviter': inviter,
        'household': householdPk,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteHouseholdInvite({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int householdInviteId
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/household_invites/'
          '/$householdInviteId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Pet>> getPets({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/pets/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => Pet.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createPet({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String petName,
    required String petType,
    required String specialInstructions,
    required String medications,
    required String foodInstructions,
    required String waterInstructions,
    required String careFrequency,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/pets/';
      final body = {
        'household': householdPk,
        'name': petName,
        'pet_type': petType,
        'special_instructions': specialInstructions,
        'medications': medications,
        'food_instructions': foodInstructions,
        'water_instructions': waterInstructions,
        'care_frequency': careFrequency,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePet({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int petId
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/pets/'
          '/$petId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Chore>> getChores({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => Chore.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createChore({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String title,
    required String description,
    required String frequency,
    required int priority,
    String? availableFrom,          // ISO‑8601 date
    String? availableUntil,         // ISO‑8601 date
    int? assignedTo,                // adult PK
    int? childAssignedTo,           // child PK
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/';

      final body = {
        'household': householdPk,
        'title': title,
        'description': description,
        'frequency': frequency,
        'priority': priority,
        if (availableFrom != null) 'available_from': availableFrom,
        if (availableUntil != null) 'available_until': availableUntil,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (childAssignedTo != null) 'child_assigned_to': childAssignedTo,
      };

      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> deleteChore({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int choreId
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/'
          '/$choreId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChoreCompletion>> getChoreCompletions({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int chorePk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/$chorePk/completions/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => ChoreCompletion.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createChoreCompletion({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int chorePk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/$chorePk/completions/';
      final body = {
        'homelife_profile': homelifeProfilePk,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteChoreCompletion({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int chorePk,
    required int choreCompletionId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/$chorePk/completions/'
          '/$choreCompletionId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChildProfile>> getChildProfiles({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
        '$homelifeProfilePk/households/$householdPk/child_profiles/';
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final map = response.data as Map<String, dynamic>;
      final results = map['results'] as List;
      return results.map((e) => ChildProfile.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createChildProfile({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required String name,
    required String dateOfBirth,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/child_profiles/';
      final body = {
        'parent_profile': homelifeProfilePk,
        'name': name,
        'date_of_birth': dateOfBirth
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteChildProfile({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
    required int childProfileId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
          '$homelifeProfilePk/households/$householdPk/child_profiles/$childProfileId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // household_service.dart
  Future<List<HomeLifeProfile>> getHouseholdMembers({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int? householdPk,
  }) async {
    final url =
        '/api/users/$userPk/profile/$userProfilePk/homelife_profile/'
        '$homelifeProfilePk/households/$householdPk/household_members/';
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final map = response.data as Map<String, dynamic>;
      final results = map['results'] as List;
      return results
          .map((e) => HomeLifeProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}