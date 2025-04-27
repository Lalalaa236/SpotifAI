import 'base_api.dart';

class UserApi extends BaseApi {
  static const String USER_PROFILE = '/user/profile/';
  static const String USER_PREFERENCES = '/user/preferences/';
  
  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await get(USER_PROFILE);
      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  // Update user preferences
  Future<Map<String, dynamic>> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await put(
        USER_PREFERENCES,
        data: preferences,
      );
      return response;
    } 
    catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }
}