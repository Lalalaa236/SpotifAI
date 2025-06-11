import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final double width;
  final Function(String)? onSubmitted;
  final EdgeInsetsGeometry? padding;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final String? errorText;
  final TextInputAction textInputAction;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.width = AppConstants.textFieldWidth,
    this.padding,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.errorText,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: width,
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: textInputAction,
              focusNode: focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.white70),
                ),
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white70),
                errorText: errorText,
                errorMaxLines: 3,
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
