import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme for OfferNepal
/// Modeled after modern neo-banking & premium lifestyle voucher apps:
/// - Crisp Pitch Black Onyx (#0D0D12 / #111116)
/// - Soft Ceramic Milk Lavender Canvas (#ECEAF6)
/// - Curated Pastel Palette:
///   * Periwinkle Lavender: #9F8EFC
///   * Cantaloupe / Peach:  #FF8652
///   * Canary Yellow:       #FFD94A
///   * Mint Green:          #76EDB8
///   * Coral Red:           #FF5C67
/// - Tight typography tracking with Plus Jakarta Sans
/// - Multi-layer ambient diffuse shadows
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // 1. BRAND COLOR PALETTE (DESIGN TOKENS)
  // ===========================================================================

  // Canvas & Surfaces
  static const Color canvasBg = Color(0xFFECEAF6);
  static const Color canvasWhite = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF3F2F9);

  // Pitch Black Onyx Anchors (Screenshot Top Header & Pill Dock)
  static const Color darkAnchor = Color(0xFF0D0D12);
  static const Color darkPill = Color(0xFF111116);
  static const Color darkCard = Color(0xFF181820);

  // Signature Pastel Card Palette (1:1 with Wallet Deck & Categories)
  static const Color pastelPeriwinkle = Color(0xFF9F8EFC);
  static const Color pastelPeach = Color(0xFFFF8652);
  static const Color pastelCanary = Color(0xFFFFD94A);
  static const Color pastelMint = Color(0xFF76EDB8);
  static const Color pastelCoral = Color(0xFFFF5C67);

  // Backward compatibility aliases
  static const Color accentPeriwinkle = pastelPeriwinkle;
  static const Color accentPeriwinkleDark = Color(0xFF8270F5);
  static const Color accentMint = pastelMint;
  static const Color accentMintDark = Color(0xFF4ACF96);
  static const Color accentAmber = pastelCanary;
  static const Color accentAmberDark = Color(0xFFE8B82B);

  // Functional Status
  static const Color savingsGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);

  // Borders & Outlines
  static const Color borderSubtle = Color(0xFFE5E3F0);
  static const Color borderLight = Color(0xFFEAE8F4);

  // Typography
  static const Color textPrimary = Color(0xFF0D0D12);
  static const Color textSecondary = Color(0xFF707284);
  static const Color textMuted = Color(0xFF9E9FB0);
  static const Color textOnDark = Colors.white;

  // Legacy aliases
  static const Color primary = darkPill;
  static const Color primaryDark = darkAnchor;
  static const Color primaryLight = pastelPeriwinkle;
  static const Color pastelBg = canvasBg;
  static const Color inputFill = cardSurface;

  // ===========================================================================
  // 2. SOFT TACTILE SHADOWS (DUAL DIFFUSE)
  // ===========================================================================
  static List<BoxShadow> get softCardShadow => [
        BoxShadow(
          color: const Color(0xFF231E4B).withValues(alpha: 0.05),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF231E4B).withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardDeckShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, -6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get floatingDockShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // ===========================================================================
  // 3. LIGHT THEME CONFIGURATION
  // ===========================================================================
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: canvasBg,
      primaryColor: darkPill,
      colorScheme: const ColorScheme.light(
        primary: darkPill,
        secondary: pastelPeriwinkle,
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
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: darkPill, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: errorRed, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: errorRed, width: 1.8),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 38,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.2,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          color: textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
