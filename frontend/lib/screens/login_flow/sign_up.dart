import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Components
import '../../components/login/custom_text_field.dart';
import '../../components/login/custom_button.dart';


class SignUpWidget extends StatelessWidget {
  final int? selectedTab;
  final Function(int) onSwitchTab;

  const SignUpWidget({
    super.key,
    required this.selectedTab,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        width: 450,
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
            const CustomTextField(labelText: 'Email', hintText: 'Email'),
            const CustomTextField(
              labelText: 'Password',
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 10),

            // Sign Up button
            CustomButton(
              text: 'Sign Up',
              onPressed: () {
                // TODO: Handle sign-up logic here
              },
            ),
            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: () => onSwitchTab(0),
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
