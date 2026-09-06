import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

/// Root widget for Tubature — The Magic Plumber.
class TubatureApp extends StatelessWidget {
  const TubatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tubature',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      navigatorObservers: [routeObserver],
      home: const HomeScreen(),
    );
  }
}
