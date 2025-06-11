import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';

// Components
import '../../components/login/custom_text_field.dart';
import '../../components/login/custom_button.dart';

// APIs
import '../../apis/auth_api.dart';
import '../../apis/dio_client.dart';

class SignUpWidget extends StatefulWidget {
  final int? selectedTab;
  final Function(int) onSwitchTab;

  const SignUpWidget({
    super.key,
    required this.selectedTab,
    required this.onSwitchTab,
  });

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  bool _loading = false;

  final _emailFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _rePasswordFocus = FocusNode();

  // Field error state variables
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _rePasswordError;

  Future<void> _handleSignUp() async {
    // Reset all error messages when attempting signup
    setState(() {
      _loading = true;
      _emailError = null;
      _usernameError = null;
      _passwordError = null;
      _rePasswordError = null;
    });

    try {
      final success = await AuthApi().signup(
        _emailController.text.trim(),
        _usernameController.text.trim(),
        _passwordController.text,
        _rePasswordController.text,
      );
      if (!mounted) return;
      if (success) {
        widget.onSwitchTab(0);
      }
    } catch (e) {
      if (!mounted) return;

      // Print original error for debugging
      debugPrint('Original sign up error: $e');

      try {
        // Try to directly get validation response from API
        final response = await DioClient.instance.post(
          '/v1/accounts/signup/',
          data: {
            'email': _emailController.text.trim(),
            'username': _usernameController.text.trim(),
            'password1': _passwordController.text,
            'password2': _rePasswordController.text,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => true, // Accept any status code
          ),
        );

        if (response.statusCode == 400 && response.data is Map) {
          final Map<String, dynamic> errorData = response.data;
          final fields = errorData['form']?['fields'] as Map<String, dynamic>?;

          if (fields != null) {
            setState(() {
              if (fields['email']?['errors'] is List &&
                  (fields['email']?['errors'] as List).isNotEmpty) {
                _emailError = (fields['email']?['errors'] as List).join('\n');
              }

              if (fields['username']?['errors'] is List &&
                  (fields['username']?['errors'] as List).isNotEmpty) {
                _usernameError = (fields['username']?['errors'] as List).join(
                  '\n',
                );
              }

              if (fields['password1']?['errors'] is List &&
                  (fields['password1']?['errors'] as List).isNotEmpty) {
                _passwordError = (fields['password1']?['errors'] as List).join(
                  '\n',
                );
              }

              if (fields['password2']?['errors'] is List &&
                  (fields['password2']?['errors'] as List).isNotEmpty) {
                _rePasswordError = (fields['password2']?['errors'] as List)
                    .join('\n');
              }
            });
            return; // Successfully extracted field errors
          }
        }

        // If we couldn't extract specific field errors, show a generic error
        setState(() {
          _emailError = "Signup failed. Please check your information.";
        });
      } catch (innerError) {
        debugPrint('Error getting validation details: $innerError');
        setState(() {
          _emailError = "Signup failed. Please try again later.";
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    // Dispose focus nodes when widget is disposed
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _rePasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.9),
            ],
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
              labelText: 'Email',
              hintText: 'Email',
              controller: _emailController,
              errorText: _emailError,
              textInputAction: TextInputAction.next,
              focusNode: _emailFocus,
              onSubmitted: (_) => _usernameFocus.requestFocus(),
            ),
            CustomTextField(
              labelText: 'Username',
              hintText: 'Username',
              controller: _usernameController,
              errorText: _usernameError,
              textInputAction: TextInputAction.next,
              focusNode: _usernameFocus,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            CustomTextField(
              labelText: 'Password',
              hintText: 'Password',
              obscureText: true,
              controller: _passwordController,
              errorText: _passwordError,
              textInputAction: TextInputAction.next,
              focusNode: _passwordFocus,
              onSubmitted: (_) => _rePasswordFocus.requestFocus(),
            ),
            CustomTextField(
              labelText: 'Re-enter Password',
              hintText: 'Re-enter Password',
              obscureText: true,
              controller: _rePasswordController,
              errorText: _rePasswordError,
              textInputAction: TextInputAction.done,
              focusNode: _rePasswordFocus,
              onSubmitted: (_) {
                if (!_loading) {
                  _handleSignUp();
                }
              },
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: _loading ? 'Signing Up...' : 'Sign Up',
              onPressed: () {
                if (!_loading) {
                  _handleSignUp();
                }
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => widget.onSwitchTab(0),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    children: [
                      TextSpan(
                        text: 'Log in',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
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
