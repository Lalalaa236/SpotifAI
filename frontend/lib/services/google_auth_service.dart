import 'dart:io';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  static const String clientId = '770205980-tnleuf11rikr01sd9mq9dm2a128n7k70.apps.googleusercontent.com';
  static const String clientSecret = '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';
  static final Uri authorizationEndpoint = Uri.parse('https://accounts.google.com/o/oauth2/auth');
  static final Uri tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');
  static final List<String> scopes = ['email', 'profile'];

  static Future<oauth2.Client?> signIn() async {
    HttpServer? redirectServer;

    try {
      // Bind to an ephemeral port
      redirectServer = await HttpServer.bind('localhost', 0);

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
          'provider': 'google',
          'provider_user_id': client.credentials.accessToken, // Replace with actual user ID from Google
          'email': 'user_email@example.com', // Replace with actual email from Google
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
      print('Error during Google sign-in: $e');
      return null;
    } finally {
      await redirectServer?.close();
    }
  }

  static Future<void> logout(oauth2.Client client) async {
    client.close();
    print('Logged out from Google');
  }
}