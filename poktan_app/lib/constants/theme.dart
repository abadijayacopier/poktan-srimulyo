import 'package:flutter/material.dart';

class GojekColors {
  // Gojek Brand Colors
  static const Color primary = Color(0xFF00AA13);
  static const Color primaryDark = Color(0xFF00880C);
  static const Color primaryLight = Color(0xFF00C215);
  static const Color primarySoft = Color(0xFFF1FBF2);
  static const Color primarySuperSoft = Color(0xFFE8F7EA);

  // Accent Colors
  static const Color red = Color(0xFFEE2737);
  static const Color redSoft = Color(0xFFFDEDEE);
  static const Color blue = Color(0xFF0081A0);
  static const Color blueDark = Color(0xFF005E75);
  static const Color blueSoft = Color(0xFFE5F7FB);
  static const Color orange = Color(0xFFFF6B00);
  static const Color orangeSoft = Color(0xFFFFF0E6);
  static const Color yellow = Color(0xFFFFB800);
  static const Color yellowSoft = Color(0xFFFFF8E5);
  static const Color purple = Color(0xFF8E44AD);
  static const Color purpleSoft = Color(0xFFF4ECF7);

  // Neutral Colors
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF68737D);
  static const Color textMuted = Color(0xFF9EA7AE);
  static const Color background = Color(0xFFF6F8F9);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E9EB);
  static const Color divider = Color(0xFFEEEEEE);
}

class GojekTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GojekColors.primary,
        primary: GojekColors.primary,
        surface: GojekColors.cardBg,
      ),
      scaffoldBackgroundColor: GojekColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: GojekColors.textPrimary),
        titleTextStyle: TextStyle(
          color: GojekColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: GojekColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GojekColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      fontFamily: 'Roboto',
    );
  }
}
