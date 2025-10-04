import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class TextStyles {
  // Display Text Styles - Using Lato for headings
  static TextStyle displayLarge = GoogleFonts.lato(fontSize: 57, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.12,);
  static TextStyle displayMedium = GoogleFonts.lato(fontSize: 45, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.15,);
  static TextStyle displaySmall = GoogleFonts.lato(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.22,);

  // Headline Text Styles - Using Lato
  static TextStyle headlineLarge = GoogleFonts.lato(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25,);
  static TextStyle headlineMedium = GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.28,);
  static TextStyle headlineSmall = GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.33,);

  // Title Text Styles - Using Inter
  static TextStyle titleLarge = GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.27,);
  static TextStyle titleMedium = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.33, letterSpacing: 0.15,);

  static TextStyle titleSmall = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.5, letterSpacing: 0.1,);

  // Body Text Styles - Using Inter
  static TextStyle bodyLarge = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5, letterSpacing: 0.15,);
  static TextStyle bodyMedium = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.42, letterSpacing: 0.25,);
  static TextStyle bodySmall = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.33, letterSpacing: 0.4,);

  // Label Text Styles - Using Inter
  static TextStyle labelLarge = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.42, letterSpacing: 0.1,);
  static TextStyle labelMedium = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.33, letterSpacing: 0.5,);
  static TextStyle labelSmall = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.45, letterSpacing: 0.5,);

  // Button Text Styles - Using Inter
  static TextStyle buttonLarge = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5, letterSpacing: 0.1,);
  static TextStyle buttonMedium = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, height: 1.42, letterSpacing: 0.25,);
  static TextStyle buttonSmall = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, height: 1.33, letterSpacing: 0.4,);

  // Splash Screen Specific Styles - Using Lato
  static TextStyle splashTitle = GoogleFonts.lato(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.orange, height: 1.1,);
  static TextStyle splashSubtitle = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.3, letterSpacing: 0.5,);
}
