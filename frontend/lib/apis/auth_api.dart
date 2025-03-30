import 'package:dio/dio.dart';

class AuthAPI {
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/'));

  static Future<void> socialLogin({
    required String provider,
    required String providerUserId,
    required String email,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.post('users/social_login/', data: {
        'provider': provider,
        'provider_user_id': providerUserId,
        'email': email,
        'access_token': accessToken,
      });

      if (response.statusCode == 200) {
        print('User logged in successfully: ${response.data}');
      } else {
        print('Error during login: ${response.data}');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
  }
}