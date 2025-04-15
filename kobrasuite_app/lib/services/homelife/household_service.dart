import 'package:dio/dio.dart';
import '../../models/homelife/child_profile.dart';
import '../../models/homelife/chore.dart';
import '../../models/homelife/chore_completion.dart';
import '../../models/homelife/household.dart';
import '../../models/homelife/household_invite.dart';
import '../../models/homelife/pet.dart';

class HouseholdService {
  final Dio _dio;

  HouseholdService(this._dio);

  Future<List<Household>> getHousehold({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => Household.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createHousehold({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/';
      final body = {
        'homelife_profile': homelifeProfilePk,
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
    required int householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk';
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
    required int householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/household_invites/';
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
    required int householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/household_invites/';
      final body = {
        'homelife_profile': homelifeProfilePk,
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
    required int householdPk,
    required int householdInvitePk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/household_invites/'
          '/$householdInvitePk';
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
    required int householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
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
    required int householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/pets/';
      final body = {
        'homelife_profile': homelifeProfilePk,
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
    required int householdPk,
    required int petPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/pets/'
          '/$petPk';
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
    required int householdPk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
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
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/';
      final body = {
        'homelife_profile': homelifeProfilePk,
      };
      final response = await _dio.post(url, data: body);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteChore({
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk,
    required int chorePk
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/'
          '/$chorePk';
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
    required int householdPk,
    required int chorePk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
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
    required int householdPk,
    required int chorePk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
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
    required int householdPk,
    required int chorePk,
    required int choreCompletionPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/chores/$chorePk/completions/'
          '/$choreCompletionPk';
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
    required int householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/child_profiles';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final map = response.data as Map<String, dynamic>;
        final results = map['results'] as List;
        return results.map((e) => ChildProfile.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createChildProfile({
    ///Needs to be completed
    required int userPk,
    required int userProfilePk,
    required int homelifeProfilePk,
    required int householdPk,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/child_profiles/';
      final body = {
        'homelife_profile': homelifeProfilePk,
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
    required int householdPk,
    required int childProfileId,
  }) async {
    try {
      final url =
          '/api/users/$userPk/profile/$userProfilePk/finance_profile/'
          '$homelifeProfilePk/households/$householdPk/child_profiles/$childProfileId';
      final response = await _dio.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}