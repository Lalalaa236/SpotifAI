import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

class AddAlbumToPlaylistApi {
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

  static Future<dynamic> createPlaylistAndAddAlbum(
    String playlistName,
    int albumId,
  ) async {
    try {
      await _setCsrfTokenAndCookies();

      final createPlaylistResponse = await DioClient.instance.post(
        '/v1/playlists/',
        data: {'name': playlistName},
      );

      final playlistId = createPlaylistResponse.data['id'];

      return await DioClient.instance.post(
        '/v1/playlists/$playlistId/add_album/',
        data: {'album_id': albumId},
      );
    } catch (e) {
      throw Exception('Error creating playlist and adding album: $e');
    }
  }

  static Future<dynamic> addAlbumToExistingPlaylist(
    int playlistId,
    int albumId,
  ) async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.post(
        '/v1/playlists/$playlistId/add_album/',
        data: {'album_id': albumId},
      );

      return response;
    } catch (e) {
      print('Detailed error: $e');
      rethrow;
    }
  }
}
