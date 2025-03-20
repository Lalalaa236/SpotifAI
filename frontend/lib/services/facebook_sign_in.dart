import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> signInWithFacebook() async {
  try {
    // Begin Facebook sign in process
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    // Check if login was successful
    if (result.status == LoginStatus.success) {
      // Get the access token
      final AccessToken accessToken = result.accessToken!;
      
      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.token,
      );
      
      // Sign in with the credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      print('Facebook login failed: ${result.status}');
      return null;
    }
  } catch (e) {
    print('Error signing in with Facebook: $e');
    return null;
  }
}

void handleFacebookSignIn() async {
  final UserCredential? userCredential = await signInWithFacebook();
  
  if (userCredential != null) {
    print('Successfully signed in with Facebook: ${userCredential.user?.displayName}');
    // Add navigation or state update here
  } else {
    print('Failed to sign in with Facebook');
  }
}

