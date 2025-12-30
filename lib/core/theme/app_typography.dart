import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme {
    return TextTheme(
      // Display Large (Timer)
      displayLarge: GoogleFonts.nunito(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      
      // Headlines (Page Titles)
      headlineLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),

      // Body Text (Notes, Lists)
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.5,
      ),

      // Captions & Labels
      labelLarge: GoogleFonts.dmSans( // Buttons
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.dmSans( // Captions
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  // Shortcuts for cleaner access
  static TextStyle? get h3 => textTheme.headlineSmall;
  static TextStyle? get h4 => textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) ?? GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static TextStyle? get body => textTheme.bodyMedium;
  static TextStyle? get bodyBold => textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
  static TextStyle? get caption => textTheme.labelMedium;
}
