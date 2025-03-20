import 'package:flutter/material.dart';
import '../components/social_login_button.dart';
import '../components/custom_text_field.dart';
import '../components/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x89000000), Color(0xDD000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 734,
            height: 830,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF1E1E1E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/spotify_logo.png', height: 50),
                    const SizedBox(height: 20),
                    const Text(
                      'Log in to Spotify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SocialLoginButton(
                      icon: Icons.g_mobiledata,
                      text: 'Continue with Google',
                      onPressed: () {},
                      // onPressed: google_service.handleGoogleSignIn,
                    ),
                    SocialLoginButton(
                      icon: Icons.facebook,
                      text: 'Continue with Facebook',
                      onPressed: () {},
                      // onPressed: facebook_service.handleFacebookSignIn,
                    ),
                    SocialLoginButton(
                      icon: Icons.apple,
                      text: 'Continue with Apple',
                      onPressed: () {},
                      // onPressed: apple_service.handleAppleSignIn,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        width: 550,
                        height: 1,
                        color: Colors.white24,
                      ),
                    ),
                    const CustomTextField(
                      labelText: 'Email or username',
                      hintText: 'Email or username',
                    ),
                    const CustomTextField(
                      labelText: 'Password',
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Log In',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: RichText(
                        text: const TextSpan(
                          text: 'Forgot your password?',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Sign up for Spotify',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}