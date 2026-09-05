import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_manager.dart';

class AppTheme {
  /// Unified App Theme Data (Poppins font)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme(),
    scaffoldBackgroundColor: ColorManager.bgLight,
    primaryColor: ColorManager.red,
    colorScheme: const ColorScheme.light(
      primary: ColorManager.red,
      surface: ColorManager.cardBg,
      onSurface: ColorManager.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorManager.bgLight,
      elevation: 0,
      iconTheme: IconThemeData(color: ColorManager.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: ColorManager.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
