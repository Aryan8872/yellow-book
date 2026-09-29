import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The official Design System & Theme configuration for OfferNepal (Entertainer).
/// Reflects the custom pastel blue background, vibrant royal blue accents,
/// and trust-building security color tokens.
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // 1. BRAND COLOR PALETTE (DESIGN TOKENS)
  // ===========================================================================

  // Primary Accent — Vibrant Royal Blue
  static const Color primary = Color(0xFF346EF6);
  static const Color primaryDark = Color(0xFF0053DB);
  static const Color primaryLight = Color(0xFF818CF8);

  // Background & Surface Tokens (Soft Pastel Blue Aesthetic)
  static const Color pastelBg = Color(0xFFD3E4FE);
  static const Color cardSurface = Color(0xFFEAF1FF);
  static const Color inputFill = Color(0xFFFFFFFF);

  // Savings & ROI Accent — Emerald Mint
  static const Color savingsGreen = Color(0xFF10B981);

  // Error & Alert — Rose Crimson
  static const Color errorRed = Color(0xFFEF4444);

  // Text Tokens
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textMuted = Colors.grey;

  // ===========================================================================
  // 2. LIGHT / PASTEL THEME CONFIGURATION (DEFAULT)
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: pastelBg,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: savingsGreen,
        surface: cardSurface,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 2,
        shadowColor: primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1.8),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.normal),
      ),
    );
  }
}
