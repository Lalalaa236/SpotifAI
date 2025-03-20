import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Begin interactive sign in process
    final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
    
    // If user cancels the sign-in process
    if (gUser == null) {
      return null;
    }

    // Obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // Create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Sign in with credential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Error signing in with Google: $e');
    return null;
  }
}

void handleGoogleSignIn() async {
  final UserCredential? userCredential = await signInWithGoogle();
  
  if (userCredential != null) {
    print('Successfully signed in with Google: ${userCredential.user?.displayName}');
    // Add navigation or state update here
  } else {
    print('Failed to sign in with Google');
  }
}

