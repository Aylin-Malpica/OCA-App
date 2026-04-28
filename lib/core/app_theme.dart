import 'package:flutter/material.dart';

class AppTheme {

  /// Paleta de colores #69444B
  static const Color tulipanes = Color(0xFFF0B63E);
  static const Color marBaltico = Color(0xFF2E2A36);
  static const Color bermudas = Color(0xFF83C3DB);
  static const Color grisBermuda = Color(0xFF768CA4);
  static const Color textColor = Color(0xFF504C4C);


  static ThemeData lightTheme = ThemeData(

    scaffoldBackgroundColor: Colors.white,

    primaryColor: tulipanes,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: tulipanes,
      onPrimary: Colors.white,
      secondary: bermudas,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      background: Colors.white,
      onBackground: marBaltico,
      surface: Colors.white,
      onSurface: marBaltico,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: tulipanes,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tulipanes,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: marBaltico,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: marBaltico,
      ),
    ),

  );

}