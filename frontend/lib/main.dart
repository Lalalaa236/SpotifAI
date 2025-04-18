import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only run window size configuration on desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('SpotifAI');

    // Get screen size
    getCurrentScreen().then((screen) {
      if (screen != null) {
        final screenSize = screen.visibleFrame;
        final width = screenSize.width;
        final height = screenSize.height;

        setWindowFrame(
          Rect.fromCenter(
            center: Offset(screenSize.width / 2, screenSize.height / 2),
            width: width,
            height: height,
          ),
        );
        setWindowMinSize(const Size(1200, 600));
      }
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotify Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
