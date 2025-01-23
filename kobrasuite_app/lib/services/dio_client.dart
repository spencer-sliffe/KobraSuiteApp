// lib/services/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kobrasuite_app/services/general/auth_service.dart';
import 'package:kobrasuite_app/services/service_locator.dart';
import '../../config.dart';

class DioClient {
  // Private constructor for singleton
  DioClient._internal() {
    _initializeDio();
  }

  // Singleton instance
  static final DioClient _instance = DioClient._internal();

  // Factory constructor to return the same instance
  factory DioClient() => _instance;

  late final Dio dio;

  // Initialize Dio with interceptors
  void _initializeDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: Config.baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Authorization header if access token exists
          String? accessToken = serviceLocator<AuthService>().accessToken;
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          debugPrint(
              'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');

          // Handle Unauthorized Error (401) - Attempt to refresh token
          if (error.response?.statusCode == 401) {
            RequestOptions options = error.requestOptions;

            try {
              bool tokenRefreshed = await serviceLocator<AuthService>().refreshTokens();
              if (tokenRefreshed) {
                // Retry the original request with new token
                final String? newAccessToken = serviceLocator<AuthService>().accessToken;
                if (newAccessToken != null) {
                  options.headers['Authorization'] = 'Bearer $newAccessToken';
                  final cloneReq = await dio.request(
                    options.path,
                    data: options.data,
                    queryParameters: options.queryParameters,
                    options: Options(
                      method: options.method,
                      headers: options.headers,
                    ),
                  );
                  return handler.resolve(cloneReq);
                }
              }
            } catch (e) {
              debugPrint('Token refresh failed: $e');
              // Optionally, trigger logout or other actions
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Optionally, add a logging interceptor for development
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }
  }
}