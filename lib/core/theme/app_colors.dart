import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color paperWhite = Color(0xFFFFFFFF);
  static const Color rippleBlue = Color(0xFF5D9CEC);
  static const Color inkBlack = Color(0xFF2D3436);
  static const Color softGray = Color(0xFFF5F7FA);

  // Semantic Colors
  static const Color warmTangerine = Color(0xFFFFAD60); // Warning / Focus
  static const Color sageGreen = Color(0xFFA8D5BA);     // Success
  static const Color successGreen = sageGreen;          // Alias for success
  static const Color coralPink = Color(0xFFFF6B6B);     // Error / High Priority
  static const Color coralRed = coralPink;              // Alias for error color
  static const Color outlineGray = Color(0xFFE0E0E0);   // Borders
  static const Color background = paperWhite;           // Alias for background
  static const Color cardBackground = Color(0xFF1E1E1E); // Dark card background

  // Text Colors
  static const Color textPrimary = inkBlack;
  static const Color inkDark = inkBlack;                // Alias for primary text
  static const Color textSecondary = Color(0xFF636E72); // Slightly lighter gray for captions
  static const Color textInverse = Colors.white;
}
