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

  static Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.post(
        '/v1/playlists/$playlistId/remove_song/',
        data: {
          'song_id': songId, // Pass the song ID in the request body
        },
      );

      if (response.statusCode == 200) {
        // Successfully removed the song
        return;
      } else if (response.statusCode == 400) {
        throw Exception('Song not in playlist or invalid request');
      } else if (response.statusCode == 404) {
        throw Exception('Song not found');
      } else {
        throw Exception('Failed to remove song from playlist');
      }
    } catch (e) {
      throw Exception('Error removing song from playlist: $e');
    }
  }

  static Future<void> addSongToPlaylist(int playlistId, int songId) async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.post(
        '/v1/playlists/$playlistId/add_song/',
        data: {
          'song_id': songId, // Pass the song ID in the request body
        },
      );

      if (response.statusCode == 200) {
        // Successfully added the song
        return;
      } else if (response.statusCode == 400) {
        throw Exception('Song already in playlist or invalid request');
      } else if (response.statusCode == 404) {
        throw Exception('Song not found');
      } else {
        throw Exception('Failed to add song to playlist');
      }
    } catch (e) {
      throw Exception('Error adding song to playlist: $e');
    }
  }

  /// Delete a playlist
  static Future<void> deletePlaylist(int playlistId) async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.delete(
        '/v1/playlists/$playlistId/',
      );

      if (response.statusCode == 204) {
        // Successfully deleted the playlist
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Playlist not found');
      } else {
        throw Exception('Failed to delete playlist');
      }
    } catch (e) {
      throw Exception('Error deleting playlist: $e');
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
