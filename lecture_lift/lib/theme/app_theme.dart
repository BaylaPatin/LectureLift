import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Mint Green Color Palette - Fresh & Modern
  static const Color mintGreen = Color(0xFF7FFFD4); // Aquamarine Mint
  static const Color lightMint = Color(0xFF9FFFED); // Light Mint
  static const Color deepMint = Color(0xFF5FD8B8); // Deep Mint
  
  // Keep purple for backwards compatibility
  static const Color primaryPurple = Color(0xFF6B4CE6);
  static const Color primaryYellow = Color(0xFFFFC947);
  
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

  // Dark Theme Colors - Washed Out Dark Grey
  static const Color darkBackground = Color(0xFF3A3A3A); // Washed out dark grey
  static const Color darkSurface = Color(0xFF4A4A4A); // Slightly lighter dark grey

  // Gradient Presets for Modern Look - Mint Green
  static const LinearGradient mintGradient = LinearGradient(
    colors: [lightMint, deepMint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [
      //Color(0xFF4B0082), // Deep blue-purple (indigo)
      Color(0xFF5B0A99), // Blue-purple blend
      Color(0xFF6A0DAD), // Medium purple
     
      Color(0xFFA020F0), // Purple-magenta transition
      Color(0xFFB933EA), // Magenta blend
      Color(0xFFD946EF), // Bright magenta
      Color(0xFFE95DE8), // Magenta-pink
      
      Color(0xFFFF7F7F), // Coral/salmon
      Color(0xFFFF9578), // Coral-peach
      Color(0xFFFFAB70), // Peach
      Color(0xFFFFBA5C), // Peach-yellow
      Color(0xFFFFC947), // Yellow/gold
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient yellowGradient = LinearGradient(
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFC107), // Amber
      Color(0xFFFFB300), // Deep Amber
      Color(0xFFFFA000), // Dark Amber
      Color(0xFFFFE082), // Light Amber
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Role-based Gradients
  static LinearGradient get driverGradient => purpleGradient;
  static LinearGradient get riderGradient => purpleGradient;

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
