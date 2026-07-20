import 'package:flutter/material.dart';

enum PaletteType { blue, green, dark }

class AppTheme {
  static ThemeData getTheme(PaletteType type) {
    switch (type) {
      case PaletteType.blue:
        return _buildTheme(
          seed: const Color(0xFF1565C0),
          primary: const Color(0xFF1565C0),
          primaryDark: const Color(0xFF0D47A1),
          accent: const Color(0xFFFF6F00),
          surface: const Color(0xFFF5F5F5),
          error: const Color(0xFFD32F2F),
          brightness: Brightness.light,
        );
      case PaletteType.green:
        return _buildTheme(
          seed: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          primaryDark: const Color(0xFF1B5E20),
          accent: const Color(0xFFFFA000),
          surface: const Color(0xFFFAFAFA),
          error: const Color(0xFFD32F2F),
          brightness: Brightness.light,
        );
      case PaletteType.dark:
        return _buildTheme(
          seed: const Color(0xFF263238),
          primary: const Color(0xFF263238),
          primaryDark: const Color(0xFF1A2328),
          accent: const Color(0xFF00BFA5),
          surface: const Color(0xFFECEFF1),
          error: const Color(0xFFCF6679),
          brightness: Brightness.light,
        );
    }
  }

  static ThemeData _buildTheme({
    required Color seed,
    required Color primary,
    required Color primaryDark,
    required Color accent,
    required Color surface,
    required Color error,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      primary: primary,
      secondary: accent,
      error: error,
      surface: surface,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withAlpha(40),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return TextStyle(fontSize: 12, color: Colors.grey.shade600);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
    );
  }
}
