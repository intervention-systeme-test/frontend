import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE50914);
  static const Color primaryDark = Color(0xFFB20710);
  static const Color background = Color(0xFF070709);
  static const Color backgroundAlt = Color(0xFF111118);
  static const Color cardBackground = Color(0xFF191922);
  static const Color fieldBackground = Color(0xFF20202B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8B8C6);
  static const Color border = Color(0x33FFFFFF);
  static const Color success = Color(0xFF21BA45);
  static const Color error = Color(0xFFEB5757);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        background: AppColors.background,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ).copyWith(
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardColor: AppColors.cardBackground.withOpacity(0.9),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground.withOpacity(0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 12,
        shadowColor: AppColors.primary.withOpacity(0.15),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldBackground.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.cardBackground,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
      ),
    );
  }
}

