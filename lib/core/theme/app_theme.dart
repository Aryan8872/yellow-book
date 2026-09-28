import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The official Design System & Theme configuration for the ENTERTAINER App.
/// Designed for a premium, eye-soothing, trust-building lifestyle & savings experience.
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // 1. BRAND COLOR PALETTE (DESIGN TOKENS)
  // ===========================================================================

  // Primary Accent — Royal Electric Indigo (Trust, Luxury, Modern Tech)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Savings & ROI Accent — Emerald Mint (Wealth, Money Saved, Unlocked Offers)
  static const Color savingsGreen = Color(0xFF10B981);
  static const Color savingsGreenLight = Color(0xFF34D399);
  static const Color savingsGreenBg = Color(0x1F10B981); // 12% opacity tint

  // Promotional Accent — Sunset Amber (Featured Offers, VIP Status, Ratings)
  static const Color warmAmber = Color(0xFFF59E0B);
  static const Color warmAmberLight = Color(0xFFFBBF24);

  // Error & Alert — Rose Crimson
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedLight = Color(0xFFF87171);

  // ---------------------------------------------------------------------------
  // Dark Palette Tokens ("Obsidian Velvet" — Default Luxury Theme)
  // ---------------------------------------------------------------------------
  static const Color darkBg = Color(0xFF0B0F19);          // Rich Obsidian Base
  static const Color darkSurface = Color(0xFF111827);     // Card & Modal Surface
  static const Color darkSurfaceElevated = Color(0xFF1F2937); // Input Containers & Chips
  static const Color darkBorder = Color(0x1FFFFFFF);      // Translucent White Border (12%)
  static const Color darkTextPrimary = Color(0xFFF9FAFB);  // High-Contrast White
  static const Color darkTextSecondary = Color(0xFF9CA3AF);// Muted Slate Silver
  static const Color darkTextMuted = Color(0xFF6B7280);    // Subtle Caption Grey

  // ---------------------------------------------------------------------------
  // Light Palette Tokens ("Clean Pearl & Crisp Slate")
  // ---------------------------------------------------------------------------
  static const Color lightBg = Color(0xFFF8FAFC);         // Warm Soft Pearl
  static const Color lightSurface = Color(0xFFFFFFFF);    // Crisp White Card
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9); // Light Gray Input Container
  static const Color lightBorder = Color(0xFFE2E8F0);     // Subtle Border
  static const Color lightTextPrimary = Color(0xFF0F172A); // Deep Slate Navy
  static const Color lightTextSecondary = Color(0xFF64748B); // Muted Steel
  static const Color lightTextMuted = Color(0xFF94A3B8);   // Soft Caption

  // ===========================================================================
  // 2. DARK THEME CONFIGURATION (DEFAULT)
  // ===========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: savingsGreen,
        tertiary: warmAmber,
        surface: darkSurface,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),

      // System Navigation & Status Bar Overlay
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),

      // Card & Container Styling
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
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
        hintStyle: const TextStyle(color: darkTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
        errorStyle: const TextStyle(color: errorRedLight, fontSize: 12),
      ),

      // Elevated Button Theme
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

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: darkTextPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(color: darkTextPrimary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        titleLarge: TextStyle(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(color: darkTextMuted, fontSize: 12, fontWeight: FontWeight.normal),
      ),
    );
  }

  // ===========================================================================
  // 3. LIGHT THEME CONFIGURATION
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: savingsGreen,
        tertiary: warmAmber,
        surface: lightSurface,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
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
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceElevated,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        hintStyle: const TextStyle(color: lightTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
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
          ),
        ),
      ),
    );
  }
}
