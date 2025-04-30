import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

class AlbumSongApi {
  static Future<List<dynamic>> getAllAlbums() async {
    try {
      // Ensure CSRF token and cookies are set
      await _setCsrfTokenAndCookies();

      // Fetch all albums
      final response = await DioClient.instance.get('/v1/albums/');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch albums');
      }
    } catch (e) {
      throw Exception('Error fetching albums: $e');
    }
  }

  static Future<List<dynamic>> getSongsOfAlbum(int albumId) async {
    try {
      // Ensure CSRF token and cookies are set
      await _setCsrfTokenAndCookies();

      // Fetch songs of a specific album
      final response = await DioClient.instance.get(
        '/v1/albums/$albumId/songs/',
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch songs for album $albumId');
      }
    } catch (e) {
      throw Exception('Error fetching songs for album $albumId: $e');
    }
  }

  static Future<Map<String, dynamic>> getSongDetails(int songId) async {
    try {
      // Ensure CSRF token and cookies are set
      await _setCsrfTokenAndCookies();

      // Fetch details of a specific song
      final response = await DioClient.instance.get(
        '/v1/songs/$songId/details/',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch details for song $songId');
      }
    } catch (e) {
      throw Exception('Error fetching details for song $songId: $e');
    }
  }

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
