import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6B46C1),
      secondary: const Color(0xFF10B981),
      surface: Colors.white,
      // Use surfaceVariant instead of deprecated background
      surfaceVariant: Colors.grey[50]!,
      // Or use scaffoldBackgroundColor in ThemeData instead
    ),
    // Set scaffold background color here instead
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6B46C1),
      secondary: Color(0xFF10B981),
      surface: Color(0xFF1E1E1E),
      surfaceVariant: Color(0xFF2C2C2C),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}