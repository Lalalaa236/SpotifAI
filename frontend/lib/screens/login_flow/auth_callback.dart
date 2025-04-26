import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  _AuthCallbackScreenState createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool isProcessing = true;
  String message = "Processing authentication...";

  @override
  void initState() {
    super.initState();
    _processAuth();
  }

  Future<void> _processAuth() async {
    try {
      // In a real implementation, you would extract token from URL parameters
      // or handle it through deeplinks
      
      // For now, we'll just navigate back to home after a delay to simulate
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    } catch (e) {
      setState(() {
        isProcessing = false;
        message = "Authentication failed: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing)
              const CircularProgressIndicator()
            else
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isProcessing ? Colors.black : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isProcessing)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: const Text('Return to Login'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}