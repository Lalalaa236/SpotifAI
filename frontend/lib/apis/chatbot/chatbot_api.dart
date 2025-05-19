import 'package:shared_preferences/shared_preferences.dart';
import '../dio_client.dart';

class ChatBotApi {
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

  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    try {
      await _setCsrfTokenAndCookies();

      final response = await DioClient.instance.post(
        '/v1/chatbot/chat/',
        data: {
          'message': message,
          if (conversationId != null) 'conversation_id': conversationId,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error sending message to chatbot: $e');
    }
  }
}
