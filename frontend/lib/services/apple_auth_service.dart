import 'dart:io';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppleAuthService {
  static const String clientId = 'YOUR_APPLE_CLIENT_ID';
  static const String clientSecret = 'YOUR_APPLE_CLIENT_SECRET';
  static final Uri authorizationEndpoint = Uri.parse('https://appleid.apple.com/auth/authorize');
  static final Uri tokenEndpoint = Uri.parse('https://appleid.apple.com/auth/token');
  static final List<String> scopes = ['email', 'name'];

  static Future<oauth2.Client?> signIn() async {
    HttpServer? redirectServer;

    try {
      // Bind to an ephemeral port
      redirectServer = await HttpServer.bind('localhost', 0);

      // Dynamically construct the redirect URL
      final redirectUrl = Uri.parse('http://localhost:${redirectServer.port}/auth');
      final grant = oauth2.AuthorizationCodeGrant(
        clientId,
        authorizationEndpoint,
        tokenEndpoint,
        secret: clientSecret,
      );

      final authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);

      if (await canLaunchUrl(authorizationUrl)) {
        await launchUrl(authorizationUrl);
      } else {
        throw Exception('Could not launch $authorizationUrl');
      }

      final request = await redirectServer.first;
      final queryParams = request.uri.queryParameters;
      request.response
        ..statusCode = 200
        ..headers.set('content-type', 'text/plain')
        ..writeln('Authentication successful! You can close this tab.')
        ..close();

      final client = await grant.handleAuthorizationResponse(queryParams);

      // Send data to the backend
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/social-login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'apple',
          'provider_user_id': client.credentials.accessToken, // Replace with actual user ID from Apple
          'email': 'user_email@example.com', // Replace with actual email from Apple
          'access_token': client.credentials.accessToken,
          'refresh_token': client.credentials.refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        print('User logged in successfully: ${response.body}');
      } else {
        print('Error during login: ${response.body}');
      }

      return client;
    } catch (e) {
      print('Error during Apple sign-in: $e');
      return null;
    } finally {
      await redirectServer?.close();
    }
  }

  static Future<void> logout(oauth2.Client client) async {
    client.close();
    print('Logged out from Apple');
  }
}