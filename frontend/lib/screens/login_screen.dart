import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/background.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // Reduced blur
            child: Container(
              color: const Color.fromRGBO(
                0,
                0,
                0,
                0.4,
              ), // Lighter overlay (0.5 → 0.4)
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          Center(
            child: Container(
              width: 900,
              height: 410,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF121212),
                    Color(0xFF1E1E1E),
                  ], // Slightly lighter gradient
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header - Keep at the top

                  // Main content - Split into two columns
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left column - Login form
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/spotify.svg',
                                    height: 50,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  const Text(
                                    'SpotifAI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
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
                            ],
                          ),
                        ),

                        // Divider between columns
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(width: 1, color: Colors.white24),
                        ),

                        // Right column - Social logins
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Or login with',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SocialLoginButton(
                                icon: SvgPicture.asset(
                                  'assets/svg/google.svg',
                                  height: 25,
                                  width: 25,
                                ),
                                text: 'Continue with Google',
                                onPressed: () async {
                                  await GoogleAuthService.signIn();
                                },
                              ),
                              SocialLoginButton(
                                icon: SvgPicture.asset(
                                  'assets/svg/facebook.svg',
                                  height: 25,
                                  width: 25,
                                ),
                                text: 'Continue with Facebook',
                                onPressed: () async {
                                  await FacebookAuthService.signIn();
                                },
                              ),
                              SocialLoginButton(
                                icon: SvgPicture.asset(
                                  'assets/svg/apple.svg',
                                  height: 25,
                                  width: 25,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                text: 'Continue with Apple',
                                onPressed: () async {
                                  await AppleAuthService.signIn();
                                },
                              ),
                              const SizedBox(height: 30),
                              RichText(
                                text: const TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
