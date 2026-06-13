import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color cardBorder = Color(0xFF2C2C2E);

  static const Color gradientBlue = Color(0xFF4FACFE);
  static const Color gradientCyan = Color(0xFF00F2FE);

  static const Color splashCyan = Color(0xFF00D2FF);
  static const Color splashNavy = Color(0xFF001A40);

  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentTeal = Color(0xFF00BCD4);
  static const Color accentGreen = Color(0xFF4CAF50);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF8E8E93);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientBlue, gradientCyan],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
