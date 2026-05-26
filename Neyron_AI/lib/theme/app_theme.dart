import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cosmicDeep,
      primaryColor: AppColors.neuronGreen,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neuronGreen,
        secondary: AppColors.plasmaYellow,
        surface: AppColors.cosmicMid,
        error: AppColors.accentRed,
        onPrimary: AppColors.cosmicDeep,
        onSecondary: AppColors.cosmicDeep,
        onSurface: AppColors.pureWhite,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.pureWhite,
        displayColor: AppColors.pureWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cosmicDeep,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cosmicMid,
        selectedItemColor: AppColors.neuronGreen,
        unselectedItemColor: AppColors.cosmicLight,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neuronGreen,
          foregroundColor: AppColors.cosmicDeep,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cosmicMid,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
