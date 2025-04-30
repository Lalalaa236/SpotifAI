import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'apis/dio_client.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

// Screens
import 'screens/login_flow/login_screen.dart';
import 'screens/main_flow/home_screen.dart';

// Theme
import 'theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DioClient.init();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      appWindow.maximize();
      appWindow.minSize = Size(1200, 600);
      appWindow.title = "SpotifAI";
      appWindow.show();
    });
  }

  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SpotifAI',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          // ignore: deprecated_member_use
          background: AppColors.background,
          // ignore: deprecated_member_use
          onBackground: AppColors.textPrimary,
          onPrimary: AppColors.textPrimary,
          secondary: AppColors.iconGray,
          onSecondary: AppColors.textPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: Colors.red,
          onError: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surface,
        dividerColor: AppColors.iconGray,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
      builder: (context, child) {
        return WindowBorder(
          color: Colors.transparent,
          width: 0,
          child: Column(children: [MoveWindow(), Expanded(child: child!)]),
        );
      },
    );
  }
}
