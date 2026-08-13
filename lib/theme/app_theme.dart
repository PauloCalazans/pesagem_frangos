import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primary = Color(0xFF087F72);
  static const progress = Color(0xFFD7EF68);
  static const background = Color(0xFFF6F8F7);
  static const text = Color(0xFF1B2529);

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        constraints: BoxConstraints(minHeight: 56),
      ),
    );
  }
}
