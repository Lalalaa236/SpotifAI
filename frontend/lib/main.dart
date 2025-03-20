import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only run window size configuration on desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Spotify Login');
    // Set fixed window size: both min and max are set to the same value
    const Size fixedSize = Size(1600, 920);
    setWindowMinSize(fixedSize);
    setWindowMaxSize(fixedSize);
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
