import 'base_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dio_client.dart';

class AuthApi extends BaseApi {
  static const String GOOGLE_AUTH_URL = '/auth/google/url/';
  static const String GOOGLE_CALLBACK = '/auth/google/callback/';
  static const String LOGOUT = '/auth/logout/';

  Future<String> getGoogleAuthUrl(String redirectUri) async {
    try {
      final response = await post(
        GOOGLE_AUTH_URL,
        data: {'redirect_uri': redirectUri},
      );
      return response['authorization_url'];
    } catch (e) {
      throw Exception('Failed to get authorization URL: $e');
    }
  }

  Future<bool> handleGoogleCallback(String code, String redirectUri) async {
    try {
      final response = await post(
        GOOGLE_CALLBACK,
        data: {'code': code, 'redirect_uri': redirectUri},
      );

      if (response != null && response['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['access_token']);

        if (response['user'] != null) {
          await prefs.setString('user_data', response['user'].toString());
        }

        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Failed to authenticate: $e');
    }
  }

  Future<bool> logout() async {
    try {
      await post(LOGOUT);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      return true;
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      // Step 1: Fetch CSRF token and cookies from login page
      final response = await DioClient.instance.get('/v1/accounts/login/');
      final csrfData = DioClient.getCsrfTokenAndCookies(response);
      final csrfToken = csrfData['csrfToken']!;
      final cookies = csrfData['cookies']!;

      // Step 2: Set CSRF token and cookies in headers for login request
      DioClient.instance.options.headers['X-CSRFToken'] = csrfToken;
      DioClient.instance.options.headers['Cookie'] = cookies;

      // Step 3: Send login request
      final loginResponse = await DioClient.instance.post(
        '/v1/accounts/login/',
        data: 'login=$email&password=$password',
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      // Step 4: On success, save new cookies and CSRF token from Set-Cookie
      if (loginResponse.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final updatedCsrfData = DioClient.getCsrfTokenAndCookies(loginResponse);
        await prefs.setString('cookies', updatedCsrfData['cookies']!);
        await prefs.setString('csrf_token', updatedCsrfData['csrfToken']!);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> signup(String email, String username, String password1, String password2) async {
    try {
      // Step 1: Fetch CSRF token and cookies from signup page
      final response = await DioClient.instance.get('/v1/accounts/signup/');
      final csrfData = DioClient.getCsrfTokenAndCookies(response);
      final csrfToken = csrfData['csrfToken']!;
      final cookies = csrfData['cookies']!;

      // Step 2: Set CSRF token and cookies in headers for signup request
      DioClient.instance.options.headers['X-CSRFToken'] = csrfToken;
      DioClient.instance.options.headers['Cookie'] = cookies;

      // Step 3: Prepare the signup data
      final data = {
        'email': email,
        'username': username,
        'password1': password1,
        'password2': password2,
      };

      // Step 4: Send the signup request
      final signupResponse = await DioClient.instance.post(
        '/v1/accounts/signup/',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      // Step 5: Handle the response
      if (signupResponse.statusCode == 201 || signupResponse.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final updatedCsrfData = DioClient.getCsrfTokenAndCookies(signupResponse);
        await prefs.setString('cookies', updatedCsrfData['cookies']!);
        await prefs.setString('csrf_token', updatedCsrfData['csrfToken']!);
        return true;
      } else {
        throw Exception(signupResponse.data['form']['errors']?.join('\n') ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }
}
