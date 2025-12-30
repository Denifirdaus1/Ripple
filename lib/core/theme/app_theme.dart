import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paperWhite,
      primaryColor: AppColors.rippleBlue,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.rippleBlue,
        secondary: AppColors.warmTangerine,
        surface: AppColors.paperWhite,
        error: AppColors.coralPink,
        onPrimary: Colors.white,
        onSecondary: AppColors.inkBlack,
        onSurface: AppColors.inkBlack,
        onError: Colors.white,
      ),

      // Typography
      textTheme: AppTypography.textTheme,
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rippleBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.outlineGray, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.rippleBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paperWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.inkBlack),
      ),
    );
  }
}
