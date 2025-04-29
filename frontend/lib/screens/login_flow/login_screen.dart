import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/login/social_login_button.dart';
import '../../components/login/custom_text_field.dart';
import '../../components/login/custom_button.dart';

import '../../services/google_auth_service.dart';
import '../../services/facebook_auth_service.dart';
import '../../services/apple_auth_service.dart';
import '../../apis/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var selectedTab = 0;
  bool isLoading = false;
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void switchTab(tab) => setState(() {
    selectedTab = tab;
  });
  
  Future<void> _handleGoogleLogin() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final Uri googleAuthUrl = Uri.parse('http://127.0.0.1:8000/api/v1/accounts/google/login/');
      
      if (await canLaunchUrl(googleAuthUrl)) {
        await launchUrl(
          googleAuthUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorSnackBar('Could not launch Google authentication');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Email and password cannot be empty');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await AuthApi.login(email, password);
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorSnackBar('Invalid email or password');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedTab) {
      case 0:
        page = LogInWidget(
          selectedTab: selectedTab, 
          onSwitchTab: switchTab,
          onGoogleLogin: _handleGoogleLogin,
          emailController: emailController,
          passwordController: passwordController,
          onLogin: _handleLogin,
          isLoading: isLoading,
        );
        break;
      case 1:
        page = SignUpWidget(selectedTab: selectedTab, onSwitchTab: switchTab);
        break;
      default:
        throw UnimplementedError('no widget found');
    }

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
          
          // Main content
          isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : page,
        ],
      ),
    );
  }
}

class LogInWidget extends StatelessWidget {
  final int selectedTab;
  final Function(int) onSwitchTab;
  final Function() onGoogleLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function() onLogin;
  final bool isLoading;

  const LogInWidget({
    super.key,
    required this.selectedTab,
    required this.onSwitchTab,
    required this.onGoogleLogin,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
                        CustomTextField(
                          controller: emailController,
                          labelText: 'Email or username',
                          hintText: 'Email or username',
                        ),
                        CustomTextField(
                          controller: passwordController,
                          labelText: 'Password',
                          hintText: 'Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          text: 'Log In',
                          onPressed: onLogin,
                        ),
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
                          onPressed: onGoogleLogin,
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
                        GestureDetector(
                          onTap: () => onSwitchTab(1),
                          child: RichText(
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
    );
  }
}

class SignUpWidget extends StatelessWidget {
  final int selectedTab;
  final Function(int) onSwitchTab;

  const SignUpWidget({
    super.key,
    required this.selectedTab,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 450,
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
            const CustomTextField(labelText: 'Email', hintText: 'Email'),
            const CustomTextField(
              labelText: 'Password',
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 10),
            CustomButton(text: 'Sign Up', onPressed: () {}),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => onSwitchTab(0),
                child: RichText(
                  text: const TextSpan(
                    text: 'Already have account? ',
                    style: TextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: 'Log in',
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
            ),
          ],
        ),
      ),
    );
  }
}
