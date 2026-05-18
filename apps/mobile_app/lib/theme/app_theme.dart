import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6D1D36); // Deep Burgundy
  static const Color scaffoldBackgroundColor = Color(0xFFFFF8F7); // Soft Cream
  static const Color accentColor = Color(0xFFE25D7A); // Soft Pink
  
  // Semantic Colors
  static const Color successColor = Color(0xFF43B98A);
  static const Color successDarkColor = Color(0xFF2B7A5A);
  static const Color warningColor = Color(0xFFFFC857);
  static const Color warningDarkColor = Color(0xFFA87E00);
  
  // Neutral Colors
  static const Color surfaceColor = Colors.white;
  static const Color onSurfaceColor = Color(0xFF1E1E1E);
  static const Color onSurfaceVariantColor = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: accentColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurfaceColor,
      ),
      textTheme: GoogleFonts.openSansTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: onSurfaceColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.poppins(
          color: onSurfaceColor,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.poppins(
          color: onSurfaceColor,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: onSurfaceColor,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.openSans(
          color: onSurfaceColor,
        ),
        bodyMedium: GoogleFonts.openSans(
          color: onSurfaceVariantColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: GoogleFonts.poppins(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
