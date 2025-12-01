import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Purple and Yellow Color Palette - Modern & Unique
  static const Color primaryPurple = Color(0xFF6B4CE6); // Vibrant Purple
  static const Color deepPurple = Color(0xFF4A2FB8); // Deep Purple (darker shade)
  static const Color lightPurple = Color(0xFF9B8FF5); // Light Purple (for accents)
  
  static const Color primaryYellow = Color(0xFFFFC947); // Warm Golden Yellow
  static const Color brightYellow = Color(0xFFFFD666); // Bright Yellow (lighter shade)
  static const Color deepYellow = Color(0xFFE6B031); // Deep Yellow (darker shade)
  
  // Neutral Colors
  static const Color surfaceColor = Colors.white;
  static const Color darkGrey = Color(0xFF2D2D2D);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFE0E0E0);
  
  // Accent & State Colors
  static const Color errorColor = Color(0xFFE63946);
  static const Color successColor = Color(0xFF06D6A0);
  
  // Backward compatibility getters for existing code
  // Pink Color for Gradients
  static const Color primaryPink = Color(0xFFFF69B4); // Hot Pink
  static const Color deepPink = Color(0xFFC51162); // Deep Pink

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A2E); // Dark Blue/Grey
  static const Color darkSurface = Color(0xFF16213E); // Slightly lighter dark

  // Gradient Presets for Modern Look
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [primaryPurple, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient yellowGradient = LinearGradient(
    colors: [primaryYellow, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Role-based Gradients
  static LinearGradient get driverGradient => purpleGradient;
  static LinearGradient get riderGradient => purpleGradient; // Unified gradient as requested

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: darkBackground, // Dark Background
      colorScheme: ColorScheme.dark( // Switch to dark scheme
        primary: primaryPurple,
        secondary: primaryYellow,
        tertiary: primaryPink,
        surface: darkSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.white,
        background: darkBackground,
        onBackground: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white70,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // Transparent for glass effect
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.15,
        ),
      ),
      // ... keep other themes if needed, but we are making custom buttons
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.white38),
        labelStyle: GoogleFonts.inter(color: Colors.white70),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }
  
  // Backward compatibility getters
  static Color get primaryColor => primaryPurple;
  static Color get secondaryColor => primaryYellow;
  static Color get backgroundColor => darkBackground; // Update getter
}
