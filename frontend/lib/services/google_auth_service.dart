import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../apis/api_manager.dart';

class GoogleAuthService {
  static final ApiManager _apiManager = ApiManager();

  static Future<bool> signIn() async {
    HttpServer? redirectServer;

    try {
      redirectServer = await HttpServer.bind('localhost', 0);
      final redirectUrl = Uri.parse('http://localhost:${redirectServer.port}/auth');
      final authorizationUrl = await _apiManager.auth.getGoogleAuthUrl(redirectUrl.toString());
      final Uri authUri = Uri.parse(authorizationUrl);
      if (await canLaunchUrl(authUri)) {
        await launchUrl(authUri);
      } 
      else {
        throw Exception('Could not launch $authorizationUrl');
      }

      final request = await redirectServer.first;
      final queryParams = request.uri.queryParameters;
      request.response
        ..statusCode = 200
        ..headers.set('content-type', 'text/plain')
        ..writeln('Authentication successful! You can close this tab.')
        ..close();

      return await _apiManager.auth.handleGoogleCallback(
        queryParams['code'] ?? '',
        redirectUrl.toString(),
      );
    } 
    catch (e) {
      print('Error during Google sign-in: $e');
      return false;
    } 
    finally {
      await redirectServer?.close();
    }
  }

  static Future<void> logout() async {
    try {
      await _apiManager.auth.logout();
    } 
    catch (e) {
      print('Error during logout: $e');
    }
  }
}