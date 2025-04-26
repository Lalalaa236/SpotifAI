import 'dart:io';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FacebookAuthService {
  static const String clientId = '661159376448852';
  static const String clientSecret = 'dc9ab97ae9ff2668973625757bd9b07a';
  static final Uri authorizationEndpoint = Uri.parse('https://www.facebook.com/v10.0/dialog/oauth');
  static final Uri tokenEndpoint = Uri.parse('https://graph.facebook.com/v10.0/oauth/access_token');
  static final List<String> scopes = ['email', 'public_profile'];

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
          'provider': 'facebook',
          'provider_user_id': client.credentials.accessToken, // Replace with actual user ID from Facebook
          'email': 'user_email@example.com', // Replace with actual email from Facebook
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
      print('Error during Facebook sign-in: $e');
      return null;
    } finally {
      await redirectServer?.close();
    }
  }

  static Future<void> logout(oauth2.Client client) async {
    client.close();
    print('Logged out from Facebook');
  }
}