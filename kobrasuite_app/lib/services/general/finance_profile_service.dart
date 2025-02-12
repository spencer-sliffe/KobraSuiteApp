// lib/services/general/finance_profile_service.dart

import 'package:dio/dio.dart';
import '../../models/finance/finance_profile.dart';

class FinanceProfileService {
  final Dio _dio;

  // Constructor with dependency injection
  FinanceProfileService(this._dio);

  /// Retrieves the FinanceProfile for a specific user and financeProfile ID.
  Future<FinanceProfile?> getFinanceProfile({
    required int userPk,
    required int financeProfilePk,
  }) async {
    final uri = '/api/users/$userPk/finance_profile/$financeProfilePk/';
    try {
      final response = await _dio.get(
        uri,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return FinanceProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching Finance Profile: $e');
    }
  }

  /// Updates the FinanceProfile for a specific user and financeProfile ID.
  Future<FinanceProfile?> updateFinanceProfile({
    required int userPk,
    required int financeProfilePk,
    required Map<String, dynamic> updatedData,
  }) async {
    final uri = '/api/users/$userPk/finance_profile/$financeProfilePk/';
    try {
      final response = await _dio.put(
        uri,
        data: updatedData,
        // Headers are managed by DioClient's interceptor
      );
      if (response.statusCode == 200) {
        return FinanceProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error updating Finance Profile: $e');
    }
  }
}