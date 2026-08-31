import 'package:flutter/material.dart';

abstract final class OneBeatTheme {
  static const _ink = Color(0xFF111827);
  static const _violet = Color(0xFF6D5DFB);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _violet,
      surface: const Color(0xFFF7F7FC),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: _ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(color: _ink, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: Color(0xFF4B5563), height: 1.45),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
