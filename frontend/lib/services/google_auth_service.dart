import 'dart:io';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  static final Uri backendAuthUrl = Uri.parse('http://localhost:8000/api/auth/google/url/');
  static final Uri backendTokenUrl = Uri.parse('http://localhost:8000/api/auth/google/callback/');

  static Future<bool> signIn() async {
    HttpServer? redirectServer;

    try {
      // Bind to an ephemeral port
      redirectServer = await HttpServer.bind('localhost', 0);
      final redirectUrl = Uri.parse('http://localhost:${redirectServer.port}/auth');
      
      // Get authorization URL from backend
      final urlResponse = await http.post(
        backendAuthUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'redirect_uri': redirectUrl.toString(),
        }),
      );
      
      if (urlResponse.statusCode != 200) {
        throw Exception('Failed to get authorization URL: ${urlResponse.body}');
      }
      
      final Map<String, dynamic> urlData = jsonDecode(urlResponse.body);
      final Uri authorizationUrl = Uri.parse(urlData['authorization_url']);
      
      // Launch the authorization URL
      if (await canLaunchUrl(authorizationUrl)) {
        await launchUrl(authorizationUrl);
      } else {
        throw Exception('Could not launch $authorizationUrl');
      }

      // Wait for the callback
      final request = await redirectServer.first;
      final queryParams = request.uri.queryParameters;
      request.response
        ..statusCode = 200
        ..headers.set('content-type', 'text/plain')
        ..writeln('Authentication successful! You can close this tab.')
        ..close();

      // Send the code to backend to complete authentication
      final response = await http.post(
        backendTokenUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': queryParams['code'],
          'redirect_uri': redirectUrl.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('User logged in successfully');
        // Store user token securely here
        return true;
      } else {
        print('Error during login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during Google sign-in: $e');
      return false;
    } finally {
      await redirectServer?.close();
    }
  }

  static Future<void> logout() async {
    // Call your backend logout endpoint
    try {
      await http.post(Uri.parse('http://localhost:8000/api/auth/logout/'));
      print('Logged out from Google');
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}