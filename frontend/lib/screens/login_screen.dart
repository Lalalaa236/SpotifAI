import 'package:flutter/material.dart';
import '../components/social_login_button.dart';
import '../components/custom_text_field.dart';
import '../components/custom_button.dart';
import '../services/google_auth_service.dart';
import '../services/facebook_auth_service.dart';
import '../services/apple_auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final halfWidth = MediaQuery.of(context).size.width * 0.32;

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
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
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
                      onPressed: () async {
                        await GoogleAuthService.signIn();
                      },
                    ),
                    SocialLoginButton(
                      icon: Icons.facebook,
                      text: 'Continue with Facebook',
                      onPressed: () async {
                        await FacebookAuthService.signIn();
                      },
                    ),
                    SocialLoginButton(
                      icon: Icons.apple,
                      text: 'Continue with Apple',
                      onPressed: () async {
                        await AppleAuthService.signIn();
                      },
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
                    CustomButton(text: 'Log In', onPressed: () {}),
                    const SizedBox(height: 10),
                    Center(
                      child: RichText(
                        text: const TextSpan(
                          text: 'Forgot your password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
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

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildSocialLoginButton(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
