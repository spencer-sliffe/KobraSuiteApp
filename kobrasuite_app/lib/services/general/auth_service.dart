import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../config.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final String _baseUrl = Config.baseUrl;

  String? _accessToken;
  String? _refreshToken;
  int? _loggedInUserId;
  String? _loggedInUsername;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get loggedInUserId => _loggedInUserId;
  String? get loggedInUsername => _loggedInUsername;
  String get baseUrl => _baseUrl;

  AuthService(this._dio, this._secureStorage);

  Future<void> initialize() async {
    _accessToken = await _secureStorage.read(key: 'accessToken');
    _refreshToken = await _secureStorage.read(key: 'refreshToken');
    final userIdString = await _secureStorage.read(key: 'loggedInUserId');
    _loggedInUserId = userIdString != null ? int.tryParse(userIdString) : null;
    _loggedInUsername = await _secureStorage.read(key: 'loggedInUsername');

    if (_accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login/',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        final userObj = data['user'] ?? {};
        _loggedInUserId = userObj['id'];
        _loggedInUsername = userObj['username'];

        await _saveTokens(access: _accessToken!, refresh: _refreshToken!);
        await _secureStorage.write(key: 'loggedInUserId', value: _loggedInUserId.toString());
        await _secureStorage.write(key: 'loggedInUsername', value: _loggedInUsername!);

        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';

        notifyListeners();

        return {
          'success': true,
          'message': 'Logged in successfully.',
          'user': userObj,
          'access': _accessToken,
          'refresh': _refreshToken,
        };
      } else {
        return {
          'success': false,
          'errors': 'Invalid response status: ${response.statusCode}',
        };
      }
    } on DioError catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'errors': e.response?.data ?? 'Unknown error occurred.',
        };
      } else {
        return {
          'success': false,
          'errors': 'Connection error: ${e.message}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'errors': 'Login failed: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register/',
        data: {
          'username': username,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        final userObj = data['user'] ?? {};
        _loggedInUserId = userObj['id'];
        _loggedInUsername = userObj['username'];

        await _saveTokens(access: _accessToken!, refresh: _refreshToken!);
        await _secureStorage.write(key: 'loggedInUserId', value: _loggedInUserId.toString());
        await _secureStorage.write(key: 'loggedInUsername', value: _loggedInUsername!);

        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';

        notifyListeners();

        return {
          'success': true,
          'message': 'User registered successfully.',
          'user': userObj,
          'access': _accessToken,
          'refresh': _refreshToken,
        };
      } else {
        return {
          'success': false,
          'errors': 'Invalid response status: ${response.statusCode}',
        };
      }
    } on DioError catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'errors': e.response?.data ?? 'Unknown error occurred.',
        };
      } else {
        return {
          'success': false,
          'errors': 'Connection error: ${e.message}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'errors': 'Registration failed: $e',
      };
    }
  }

  /// Grabs up-to-date user info from the server.
  Future<Map<String, dynamic>> whoami() async {
    if (_accessToken == null) {
      return {'success': false, 'errors': 'No access token'};
    }
    try {
      final response = await _dio.get('/api/auth/whoami/');
      if (response.statusCode == 200) {
        final data = response.data;
        final userObj = data['user'] ?? {};
        // update local fields so we remain consistent
        _loggedInUserId = userObj['id'];
        _loggedInUsername = userObj['username'] ?? 'unknown';

        await _secureStorage.write(
            key: 'loggedInUserId', value: _loggedInUserId.toString());
        await _secureStorage.write(
            key: 'loggedInUsername', value: _loggedInUsername!);

        notifyListeners();
        return {'success': true, 'user': userObj};
      } else {
        return {
          'success': false,
          'errors': 'Invalid response status: ${response.statusCode}'
        };
      }
    } on DioError catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'errors': e.response?.data ?? 'Unknown error occurred.',
        };
      } else {
        return {
          'success': false,
          'errors': 'Connection error: ${e.message}',
        };
      }
    } catch (e) {
      return {'success': false, 'errors': 'Whoami failed: $e'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post(
        '/api/auth/logout/',
        data: {'refresh': _refreshToken},
      );
      if (response.statusCode == 200) {
        _accessToken = null;
        _refreshToken = null;
        _loggedInUserId = null;
        _loggedInUsername = null;

        await _clearTokens();
        _dio.options.headers.remove('Authorization');
        notifyListeners();

        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {
          'success': false,
          'errors': 'Invalid response status: ${response.statusCode}'
        };
      }
    } on DioError catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'errors': e.response?.data ?? 'Unknown error occurred.',
        };
      } else {
        return {
          'success': false,
          'errors': 'Connection error: ${e.message}',
        };
      }
    } catch (e) {
      return {'success': false, 'errors': 'Logout failed: $e'};
    }
  }

  Future<bool> refreshTokens() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/api/token/refresh/', // <<== MUST match your backend's refresh route
        data: {'refresh': _refreshToken},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        _accessToken = data['access'];
        if (data['refresh'] != null) {
          _refreshToken = data['refresh'];
        }
        await _saveTokens(
          access: _accessToken!,
          refresh: _refreshToken!,
        );
        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
        notifyListeners();
        return true;
      }
      return false;
    } on DioError catch (e) {
      debugPrint('Token refresh failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error during token refresh: $e');
      return false;
    }
  }

  Future<void> _saveTokens({required String access, required String refresh}) async {
    await _secureStorage.write(key: 'accessToken', value: access);
    await _secureStorage.write(key: 'refreshToken', value: refresh);
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    await _secureStorage.delete(key: 'loggedInUserId');
    await _secureStorage.delete(key: 'loggedInUsername');
  }
}