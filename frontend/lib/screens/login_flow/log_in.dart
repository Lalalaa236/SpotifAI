import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

// Components
import '../../components/login/social_login_button.dart';
import '../../components/login/custom_text_field.dart';
import '../../components/login/custom_button.dart';

// Services
import '../../services/facebook_auth_service.dart';
import '../../services/apple_auth_service.dart';

class LogInWidget extends StatefulWidget {
  final int? selectedTab;
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
  State<LogInWidget> createState() => _LogInWidgetState();
}

class _LogInWidgetState extends State<LogInWidget> {
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        widget.onLogin(); // Trigger login on Enter key press
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyPress,
      child: Center(
        child: Container(
          width: 900,
          height: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.9),
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
                                colorFilter: ColorFilter.mode(
                                  colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text('SpotifAI', style: textTheme.titleLarge),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: widget.emailController,
                            labelText: 'Email or username',
                            hintText: 'Email or username',
                            focusNode: emailFocusNode, // Attach focus node
                          ),
                          CustomTextField(
                            controller: widget.passwordController,
                            labelText: 'Password',
                            hintText: 'Password',
                            obscureText: true,
                            focusNode: passwordFocusNode, // Attach focus node
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: 'Log In',
                            onPressed: widget.onLogin,
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot your password?',
                                style: textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
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
                      child: Container(
                        width: 1,
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),

                    // Right column - Social logins
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Or login with', style: textTheme.bodyLarge),
                          const SizedBox(height: 20),
                          SocialLoginButton(
                            icon: SvgPicture.asset(
                              'assets/svg/google.svg',
                              height: 25,
                              width: 25,
                            ),
                            text: 'Continue with Google',
                            onPressed: widget.onGoogleLogin,
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
                              colorFilter: ColorFilter.mode(
                                colorScheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                            text: 'Continue with Apple',
                            onPressed:
                                () async => await AppleAuthService.signIn(),
                          ),
                          const SizedBox(height: 30),
                          TextButton(
                            onPressed: () => widget.onSwitchTab(1),
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign up for Spotify',
                                    style: textTheme.bodyMedium?.copyWith(
                                      decoration: TextDecoration.underline,
                                      color: colorScheme.onSurface,
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
            ],
          ),
        ),
      ),
    );
  }
}
