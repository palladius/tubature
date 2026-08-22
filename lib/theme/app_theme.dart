import 'package:flutter/material.dart';

/// App-wide theme for Tubature — kid-friendly, colorful, large touch targets.
class AppTheme {
  AppTheme._();

  /// Warm cream background matching the game aesthetic
  static const Color backgroundCream = Color(0xFFF5F0EB);

  /// The main Material theme for the app.
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF333333),
          size: 28,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(200, 56), // Kid-friendly tap target
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF555555),
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Color(0xFF444444),
        ),
      ),
    );
  }
}
