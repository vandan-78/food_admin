import 'package:flutter/material.dart';
import 'package:food_admin_app/core/text_styles.dart';
import 'app_colors.dart';


class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.orange,
    colorScheme: ColorScheme.light(
      primary: AppColors.orange,
      secondary: AppColors.orange,
      surface: Colors.white,
      background: AppColors.backgroundLight,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: TextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyles.displayLarge,
      displayMedium: TextStyles.displayMedium,
      displaySmall: TextStyles.displaySmall,
      headlineLarge: TextStyles.headlineLarge,
      headlineMedium: TextStyles.headlineMedium,
      headlineSmall: TextStyles.headlineSmall,
      titleLarge: TextStyles.titleLarge,
      titleMedium: TextStyles.titleMedium,
      titleSmall: TextStyles.titleSmall,
      bodyLarge: TextStyles.bodyLarge,
      bodyMedium: TextStyles.bodyMedium,
      bodySmall: TextStyles.bodySmall,
      labelLarge: TextStyles.labelLarge,
      labelMedium: TextStyles.labelMedium,
      labelSmall: TextStyles.labelSmall,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.orange),
      ),
      labelStyle: TextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyles.buttonLarge.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.orange,
      unselectedItemColor: AppColors.gray600,
      selectedLabelStyle: TextStyles.labelSmall.copyWith(
        color: AppColors.orange,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyles.labelSmall.copyWith(
        color: AppColors.gray600,
        fontWeight: FontWeight.w500,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.gray300,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.orange,
      secondary: AppColors.orange,
      surface: AppColors.gray800,
      background: AppColors.backgroundDark,
      onSurface: AppColors.textDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.gray800,
      foregroundColor: AppColors.textDark,
      titleTextStyle: TextStyles.titleLarge.copyWith(color: AppColors.textDark),
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyles.displayLarge.copyWith(color: AppColors.textDark),
      displayMedium: TextStyles.displayMedium.copyWith(color: AppColors.textDark),
      displaySmall: TextStyles.displaySmall.copyWith(color: AppColors.textDark),
      headlineLarge: TextStyles.headlineLarge.copyWith(color: AppColors.textDark),
      headlineMedium: TextStyles.headlineMedium.copyWith(color: AppColors.textDark),
      headlineSmall: TextStyles.headlineSmall.copyWith(color: AppColors.textDark),
      titleLarge: TextStyles.titleLarge.copyWith(color: AppColors.textDark),
      titleMedium: TextStyles.titleMedium.copyWith(color: AppColors.textDark),
      titleSmall: TextStyles.titleSmall.copyWith(color: AppColors.textDark),
      bodyLarge: TextStyles.bodyLarge.copyWith(color: AppColors.textDark),
      bodyMedium: TextStyles.bodyMedium.copyWith(color: AppColors.textDark),
      bodySmall: TextStyles.bodySmall.copyWith(color: AppColors.textDark),
      labelLarge: TextStyles.labelLarge.copyWith(color: AppColors.textDark),
      labelMedium: TextStyles.labelMedium.copyWith(color: AppColors.textDark),
      labelSmall: TextStyles.labelSmall.copyWith(color: AppColors.textDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gray700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gray700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.orange),
      ),
      labelStyle: TextStyles.bodyMedium.copyWith(
        color: AppColors.gray400,
      ),
      hintStyle: TextStyles.bodyMedium.copyWith(
        color: AppColors.gray500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyles.buttonLarge.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.gray900,
      selectedItemColor: AppColors.orange,
      unselectedItemColor: AppColors.gray400,
      selectedLabelStyle: TextStyles.labelSmall.copyWith(
        color: AppColors.orange,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyles.labelSmall.copyWith(
        color: AppColors.gray400,
        fontWeight: FontWeight.w500,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: AppColors.gray800,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.gray700,
      thickness: 1,
      space: 1,
    ),
  );
}