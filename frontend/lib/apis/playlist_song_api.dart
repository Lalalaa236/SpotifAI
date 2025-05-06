import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

class PlaylistSongApi {
  /// Fetch all playlists of the current user
  static Future<List<dynamic>> getUserPlaylists() async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.get('/v1/playlists/');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch playlists');
      }
    } catch (e) {
      throw Exception('Error fetching playlists: $e');
    }
  }

  /// Reuse token + cookie setup
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
}
