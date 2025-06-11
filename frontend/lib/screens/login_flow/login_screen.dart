import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import './sign_up.dart';
import './log_in.dart';

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
      final Uri googleAuthUrl = Uri.parse(
        'http://127.0.0.1:8000/api/v1/accounts/google/login/',
      );

      if (await canLaunchUrl(googleAuthUrl)) {
        await launchUrl(googleAuthUrl, mode: LaunchMode.externalApplication);
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
      if (!mounted) return;
      if (success) {
        context.go('/home');
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
    final colorScheme = Theme.of(context).colorScheme;

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
              color: colorScheme.surface.withValues(
                alpha: 0.6,
              ), // use themed surface
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Main content
          Column(
            children: [
              // ===== Draggable Title Bar + Buttons =====
              Container(
                color: Colors.transparent,
                height: 50,
                child: Row(
                  children: [
                    Expanded(child: MoveWindow()), // draggable area
                    Row(
                      children: [
                        MinimizeWindowButton(
                          colors: WindowButtonColors(
                            iconNormal: colorScheme.onSurface,
                          ),
                        ),
                        MaximizeWindowButton(
                          colors: WindowButtonColors(
                            iconNormal: colorScheme.onSurface,
                          ),
                        ),
                        CloseWindowButton(
                          colors: WindowButtonColors(
                            iconNormal: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : page,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
