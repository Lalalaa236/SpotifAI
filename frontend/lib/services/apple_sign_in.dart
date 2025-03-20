import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> signInWithApple() async {
  try {
    // Begin Apple sign in process
    final AuthorizationCredentialAppleID appleCredential = 
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    
    // Create an OAuthCredential
    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    
    // Sign in with the credential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Error signing in with Apple: $e');
    return null;
  }
}

void handleAppleSignIn() async {
  final UserCredential? userCredential = await signInWithApple();
  
  if (userCredential != null) {
    print('Successfully signed in with Apple: ${userCredential.user?.displayName}');
    // Add navigation or state update here
  } else {
    print('Failed to sign in with Apple');
  }
}

