// lib/utils/app_theme.dart
// Defines light and dark Material themes for the Budget Tracking App.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF2E7D32);       // Deep Green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark  = Color(0xFF1B5E20);
  static const Color accentColor  = Color(0xFF00BFA5);       // Teal accent
  static const Color errorColor   = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color successColor = Color(0xFF43A047);

  // ── Category Colors ────────────────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'Food':           Color(0xFFFF7043),
    'Transportation': Color(0xFF42A5F5),
    'Bills':          Color(0xFFAB47BC),
    'Shopping':       Color(0xFFFFCA28),
    'Salary':         Color(0xFF26A69A),
    'Others':         Color(0xFF78909C),
  };

  static Color getCategoryColor(String category) =>
      categoryColors[category] ?? const Color(0xFF78909C);

  // ── Text Theme (Poppins) ───────────────────────────────────────
  static TextTheme _buildTextTheme(Color baseColor) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge:  GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: baseColor),
      displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: baseColor),
      headlineLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: baseColor),
      headlineMedium:GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: baseColor),
      titleLarge:    GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: baseColor),
      titleMedium:   GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: baseColor),
      titleSmall:    GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: baseColor),
      bodyLarge:     GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: baseColor),
      bodyMedium:    GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: baseColor),
      bodySmall:     GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: baseColor),
      labelLarge:    GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary:   primaryColor,
        secondary: accentColor,
        error:     errorColor,
        surface:   Color(0xFFF5F7FA),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      textTheme: _buildTextTheme(const Color(0xFF1C1C1E)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1C1E),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        hintStyle:  GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary:   primaryLight,
        secondary: accentColor,
        error:     errorColor,
        surface:   Color(0xFF1C1C1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: _buildTextTheme(Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
        hintStyle:  GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C1C1E),
        selectedItemColor: primaryLight,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
