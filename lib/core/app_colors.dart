import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color backgroundLight = Color(0xFFFFF8F5); // Light orange background
  static const Color textLight = Color(0xFF333333);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color textDark = Colors.white70;

  // Primary Colors - Using light orange as requested
  static const Color primary = Color(0xFFFF7F50); // Coral
  static const Color primaryDark = Color(0xFFE57245);
  static const Color primaryLight = Color(0xFFFFA285);

  // Background Colors
  static const Color background = Color(0xFFFFF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Neutral Colors
  static const Color gray50 = Color(0xFFF8F9FA);
  static const Color gray100 = Color(0xFFF1F3F5);
  static const Color gray200 = Color(0xFFE9ECEF);
  static const Color gray300 = Color(0xFFDEE2E6);
  static const Color gray400 = Color(0xFFCED4DA);
  static const Color gray500 = Color(0xFFADB5BD);
  static const Color gray600 = Color(0xFF6C757D);
  static const Color gray700 = Color(0xFF495057);
  static const Color gray800 = Color(0xFF343A40);
  static const Color gray900 = Color(0xFF212529);

  // Orange variants for food theme
  static const Color orangeLight = Color(0xFFFFE8E0);
  static const Color orange = Color(0xFFFF7F50);
  static const Color orangeDark = Color(0xFFE57245);

  // Additional Colors
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color teal = Color(0xFF14B8A6);

  // Gradient Colors
  static final LinearGradient primaryGradient = LinearGradient(
    colors: [
      Colors.orange.shade700,
      Colors.orange.shade500,
      Colors.orange.shade300
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient successGradient = LinearGradient(
    colors: [
      Colors.green.shade700,
      Colors.green.shade500,
      Colors.green.shade300,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient errorGradient2 = LinearGradient(
    colors: [
      Colors.red.shade700,
      Colors.red.shade500,
      Colors.red.shade300,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Splash Screen Specific Colors
  static const Color splashBackgroundLight = Color(0xFFFFE8E0);
  static const Color splashAccent = Color(0xFFFF7F50);

  // Splash Gradient
  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      background,
      splashBackgroundLight,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}