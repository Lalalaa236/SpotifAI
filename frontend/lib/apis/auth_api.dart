import 'base_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    } 
    catch (e) {
      throw Exception('Failed to get authorization URL: $e');
    }
  }
  
  Future<bool> handleGoogleCallback(String code, String redirectUri) async {
    try {
      final response = await post(
        GOOGLE_CALLBACK,
        data: {
          'code': code,
          'redirect_uri': redirectUri,
        },
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
    } 
    catch (e) {
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
    } 
    catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}