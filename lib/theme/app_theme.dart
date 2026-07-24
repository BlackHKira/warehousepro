import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF152a46);
  static const orange = Color(0xFFe9873c);
  static const green = Color(0xFF2e9b73);
  static const red = Color(0xFFd76868);
  static const amber = Color(0xFFd79a3c);
  static const background = Color(0xFFf6f8fb);
  static const surface = Color(0xFFffffff);
  static const border = Color(0xFFe7ebf0);
  static const textPrimary = Color(0xFF172b43);
  static const textMuted = Color(0xFF748196);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.orange,
        onSecondary: Colors.white,
        error: AppColors.red,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: const Color(0xFFeef1f6),
        onSurfaceVariant: AppColors.textMuted,
        outline: AppColors.border,
        primaryContainer: AppColors.navy.withValues(alpha: 0.12),
        onPrimaryContainer: AppColors.navy,
        secondaryContainer: AppColors.orange.withValues(alpha: 0.12),
        onSecondaryContainer: AppColors.orange,
        errorContainer: AppColors.red.withValues(alpha: 0.12),
        onErrorContainer: AppColors.red,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.navy,
        indicatorColor: Colors.white24,
        selectedLabelTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: Colors.white60),
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Colors.white60),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.navy.withValues(alpha: 0.12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
