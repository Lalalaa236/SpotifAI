import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.green,
    this.textColor = Colors.white,
    this.width = AppConstants.buttonWidth,
    this.height = AppConstants.buttonHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
        ),
      ),
    );
  }
}
