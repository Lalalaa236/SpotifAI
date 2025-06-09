import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'apis/dio_client.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

// Screens
import 'screens/login_flow/login_screen.dart';
import 'screens/main_flow/home_screen.dart';

// Theme
import 'theme/colors.dart';

// Bloc
import 'utils/app_bloc.dart';

void main() {
  // HardwareKeyboard.instance.clearState();
  Logger.root.level = Level.ALL; // Set the logging level
  Logger.root.onRecord.listen((record) {
    // Use the logging framework instead of print
    if (record.level >= Level.SEVERE) {
      // Log severe errors
      debugPrint(
        'SEVERE: ${record.time}: ${record.loggerName}: ${record.message}',
      );
      if (record.error != null) {
        debugPrint('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        debugPrint('StackTrace: ${record.stackTrace}');
      }
    } else {
      // Log other levels
      debugPrint(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
      );
    }
  });

  WidgetsFlutterBinding.ensureInitialized();
  DioClient.init();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider<AppCubit>(create: (_) => AppCubit())],
      child: const MyApp(),
    ),
  );

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      appWindow
        ..maximize()
        ..minSize = const Size(1200, 600)
        ..title = "SpotifAI"
        ..show();
    });
  }
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
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse},
      ),
      debugShowCheckedModeBanner: false,
      title: 'SpotifAI',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: AppColors.textPrimary,
          secondary: AppColors.iconGray,
          onSecondary: AppColors.textPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          tertiary: AppColors.background,
          onTertiary: AppColors.textPrimary,
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
    );
  }
}
