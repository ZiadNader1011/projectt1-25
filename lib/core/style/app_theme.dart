import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      surface: const Color(0xff34516b),
      primary: const Color(0xFF00C853),
      onSurface: Colors.white,
      onPrimary: Colors.white,
      background: Colors.black,
      onBackground: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xff6aaac5),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00C853), // Green
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
