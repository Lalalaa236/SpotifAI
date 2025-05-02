import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

class FindArtistAndFetchSongsApi {
  static Future<void> _setCsrfTokenAndCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final csrfToken = prefs.getString('csrf_token');
    final cookies = prefs.getString('cookies');

    if (csrfToken != null && cookies != null) {
      DioClient.instance.options.headers['X-CSRFToken'] = csrfToken;
      DioClient.instance.options.headers['Cookie'] = cookies;
    } 
    else {
      throw Exception('CSRF token or cookies are missing. Please log in again.');
    }
  }

  static Future<List<dynamic>> findArtistByName(String artistName) async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.get('/v1/artists/find_artist/', queryParameters: {
        'q': artistName,
      });

      return response.data as List<dynamic>;
    } 
    catch (e) {
      throw Exception('Error finding artist by name: $e');
    }
  }

  static Future<List<dynamic>> fetchSongsByArtist(int artistId) async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.get('/v1/songs/fetch_songs_by_artist/', queryParameters: {
        'artist_id': artistId,
      });

      return response.data as List<dynamic>;
    } 
    catch (e) {
      throw Exception('Error fetching songs by artist: $e');
    }
  }
}