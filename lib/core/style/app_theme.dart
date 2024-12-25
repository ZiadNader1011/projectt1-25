import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      surface: const Color(0xff2b2be8),
      primary: const Color(0xff22CB8E),
      onSurface: Colors.white,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xff2b2be8),
  );
}
