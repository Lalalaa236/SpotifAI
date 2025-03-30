import 'dart:io';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apis/auth_api.dart';

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

      final userInfoResponse = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo?alt=json'),
        headers: {'Authorization': 'Bearer ${client.credentials.accessToken}'},
      );

      if (userInfoResponse.statusCode == 200) {
        final userInfo = json.decode(userInfoResponse.body);
        final email = userInfo['email'];
        final providerUserId = userInfo['id'];

        // Send data to the backend
        await AuthAPI.socialLogin(
          provider: 'google',
          providerUserId: providerUserId,
          email: email,
          accessToken: client.credentials.accessToken,
        );
      } else {
        print('Failed to fetch user info: ${userInfoResponse.body}');
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