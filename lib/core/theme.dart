import 'package:flutter/material.dart';

class AuroraTheme {
  // Brand Colors
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color cardBg = Color(0xFF1E293B); // Slate 800
  static const Color primary = Color(0xFF14B8A6); // Teal 500
  static const Color primaryLight = Color(0xFF2DD4BF); // Teal 400
  static const Color primaryDark = Color(0xFF0F766E); // Teal 700
  
  static const Color secondary = Color(0xFF6366F1); // Indigo 500
  static const Color secondaryLight = Color(0xFF818CF8); // Indigo 400
  
  static const Color accentHydration = Color(0xFF38BDF8); // Sky 400
  static const Color accentSleep = Color(0xFFA78BFA); // Violet 400
  static const Color accentHabits = Color(0xFF34D399); // Emerald 400
  static const Color accentNutrition = Color(0xFFFBBF24); // Amber 400
  static const Color accentStreak = Color(0xFFFB7185); // Rose 400

  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  // Gradients
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [
      Color(0xFF0F172A),
      Color(0xFF0F2D37),
      Color(0xFF0D3330),
      Color(0xFF0F172A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient indigoGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient hydrationGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        background: darkBg,
        surface: cardBg,
        error: Colors.redAccent,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        labelLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: darkBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
    );
  }
}
