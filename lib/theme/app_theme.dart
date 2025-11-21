import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.background,
  );

  static final ColorScheme _darkScheme = ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: Colors.grey.shade900,
  );

  static ThemeData lightTheme = ThemeData(
    colorScheme: _lightScheme,
    primaryColor: _lightScheme.primary,
    scaffoldBackgroundColor: _lightScheme.surface,
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
    // Card styling handled locally in widgets for maximum compatibility across SDKs.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: _darkScheme,
    primaryColor: _darkScheme.primary,
    scaffoldBackgroundColor: _darkScheme.surface,
    appBarTheme: const AppBarTheme(elevation: 0),
    // Card styling handled locally in widgets for maximum compatibility across SDKs.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodySmall: TextStyle(fontSize: 12, color: Colors.white70),
    ),
  );
}
