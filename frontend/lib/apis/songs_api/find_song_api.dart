import 'package:shared_preferences/shared_preferences.dart';
import '../dio_client.dart';

class FindSongApi {
  static Future<void> _setCsrfTokenAndCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final csrfToken = prefs.getString('csrf_token');
    final cookies = prefs.getString('cookies');

    if (csrfToken != null && cookies != null) {
      DioClient.instance.options.headers['X-CSRFToken'] = csrfToken;
      DioClient.instance.options.headers['Cookie'] = cookies;
    } else {
      throw Exception(
        'CSRF token or cookies are missing. Please log in again.',
      );
    }
  }

  static Future<List<dynamic>> findSongByName(String songName) async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.get(
        '/v1/songs/find_song/',
        queryParameters: {'q': songName},
      );

      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Error finding song by name: $e');
    }
  }
}
