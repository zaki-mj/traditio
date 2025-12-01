import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    // surface (cards/panels) should be visibly distinct from the scaffold background
    surface: AppColors.surface,
  );

  static final ColorScheme _darkScheme = ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    // darker surface for cards and panels
    surface: AppColors.surfaceDark,
  );

  static ThemeData lightTheme = ThemeData(
    colorScheme: _lightScheme,
    primaryColor: _lightScheme.primary,
    // scaffold is a soft background, keep surface for cards and panels
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
    // Make cards and popups visually separated from page background
    cardTheme: CardThemeData(
      color: _lightScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(color: AppColors.bottomNavLight, elevation: 8),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: AppColors.bottomNavLight, selectedItemColor: _lightScheme.primary, unselectedItemColor: Colors.grey[600], elevation: 8),
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
    // dark scaffold background is darker than the elevated surfaces
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(elevation: 0),
    cardTheme: CardThemeData(
      color: _darkScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(color: AppColors.bottomNavDark, elevation: 8),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: AppColors.bottomNavDark, selectedItemColor: _darkScheme.primary, unselectedItemColor: Colors.grey[400], elevation: 8),
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
