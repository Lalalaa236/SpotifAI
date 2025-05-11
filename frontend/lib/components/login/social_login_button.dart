import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.width = AppConstants.loginButtonWidth,
    this.height = AppConstants.loginButtonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Stack(
            children: [
              // Left-aligned icon
              Positioned(
                left: width * 0.1,
                top: 0,
                bottom: 0,
                child: Center(child: icon),
              ),
              // Centered text
              Center(
                child: Text(text, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
