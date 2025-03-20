import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final halfWidth = MediaQuery.of(context).size.width * 0.32;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF65D36E), // green (#65D36E)
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: halfWidth,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/spotify.svg', // update path as needed
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  height: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log in to SpotifAI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSocialLoginButton(
                  SvgPicture.asset('assets/svg/google.svg', height: 25),
                  'Continue with Google',
                ),
                _buildSocialLoginButton(
                  SvgPicture.asset('assets/svg/facebook.svg', height: 25),
                  'Continue with Facebook',
                ),
                _buildSocialLoginButton(
                  SvgPicture.asset(
                    'assets/svg/apple.svg',
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    height: 25,
                  ),
                  'Continue with Apple',
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email or username',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      _buildTextField('Email or username'),
                      const SizedBox(height: 10),
                      const Text(
                        'Password',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      _buildTextField('Password', isPassword: true),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot your password?',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: 'Sign up for Spotify',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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

  Widget _buildSocialLoginButton(Widget icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Container(
          width: 30, // Fixed width to align all icons
          alignment: Alignment.centerLeft,
          child: icon,
        ),
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
