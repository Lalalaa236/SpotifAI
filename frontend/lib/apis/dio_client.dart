import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static Dio? _dio;

  static const String BASE_URL = 'http://localhost:8000/api';

  static void init() {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: BASE_URL,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _setupInterceptors();
    }
  }

  static Dio get instance {
    if (_dio == null) {
      init();
    }
    return _dio!;
  }

  static void _setupInterceptors() {
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('Headers: ${options.headers}');
            print('Data: ${options.data}');
          }

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
            print('Data: ${response.data}');
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print(
              'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            );
            print('Message: ${e.message}');
          }

          if (e.response?.statusCode == 401) {
            // Handle token expiration or invalidation
          }

          return handler.next(e);
        },
      ),
    );
  }

  static Map<String, String> getCsrfTokenAndCookies(Response response) {
    final cookies = response.headers['set-cookie'];
    String? csrfToken;

    if (cookies != null) {
      for (var cookie in cookies) {
        if (cookie.startsWith('csrftoken=')) {
          csrfToken = cookie.split(';').first.split('=').last;
        }
      }
    }

    if (csrfToken == null) {
      throw Exception('CSRF token not found');
    }

    return {
      'csrfToken': csrfToken,
      'cookies': cookies != null ? cookies.join('; ') : '',
    };
  }
}
