import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: AppColors.ventoYellow,
      scaffoldBackgroundColor: AppColors.white,
      // Using GoogleFonts to ensure characters and fallback fonts load correctly on Web
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 58,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          letterSpacing: 1.74,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 24, color: AppColors.white),
        bodyMedium: GoogleFonts.poppins(fontSize: 18, color: AppColors.white),
        labelSmall: GoogleFonts.poppins(fontSize: 12, color: AppColors.white, fontWeight: FontWeight.w300),
      ),
    );
  }
}
