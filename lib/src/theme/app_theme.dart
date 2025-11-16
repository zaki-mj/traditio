import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(elevation: 0),
    // cardTheme: CardTheme(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(elevation: 0),
    // cardTheme: CardTheme(color: Colors.grey[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,),
  );
}
