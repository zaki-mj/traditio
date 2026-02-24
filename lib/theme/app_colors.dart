import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color.fromARGB(255, 75, 49, 11); // teal 700
  static const Color primaryVariant = Color(0xFF004D40);
  static const Color secondary = Color.fromARGB(255, 126, 85, 14); // amber

  // Backgrounds
  static const Color background = Color(0xFFF6F6F6);
  // Dark background behind cards / surfaces
  static const Color backgroundDark = Color(0xFF071019);

  // Surface / cards (distinct from page background)
  static const Color surface = Color(0xFFFFFFFF);
  // dark surface (for cards / panels in dark mode)
  static const Color surfaceDark = Color(0xFF111218);

  // Bottom navigation / app bars background (slightly elevated from scaffold)
  static const Color bottomNavLight = Color(0xFFFFFFFF);
  static const Color bottomNavDark = Color(0xFF0F1720);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF00796B), Color(0xFF26A69A)]);

  static const LinearGradient overlayGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color.fromARGB(55, 0, 0, 0)]);
}
