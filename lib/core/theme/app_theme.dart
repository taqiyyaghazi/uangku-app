import 'package:flutter/material.dart';

/// Ocean Flow color palette from UX Design Specification.
///
/// - Primary: Teal (#008080) — flow and clarity
/// - Secondary: Soft Grey (#F5F5F5) — backgrounds and containers
/// - Accent: Amber (#FFBF00) — gentle adjustment warnings
class OceanFlowColors {
  OceanFlowColors._();

  // ── Primary Teal ────────────────────────────────────────────────
  static const Color primary = Color(0xFF008080);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color onPrimary = Colors.white;

  // ── Secondary / Surface ─────────────────────────────────────────
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color background = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);

  // ── Accent / Warning ────────────────────────────────────────────
  static const Color accent = Color(0xFFFFBF00);
  static const Color onAccent = Color(0xFF1C1C1C);

  // ── Semantic ────────────────────────────────────────────────────
  static const Color income = Color(0xFF2E7D32); // Green
  static const Color expense = Color(0xFFC62828); // Red
  static const Color transfer = Color(0xFF1565C0); // Blue
  static const Color error = Color(0xFFB00020);
}

/// Builds the Ocean Flow [ThemeData] for light mode.
///
/// [textTheme] and [titleTextStyle] are injectable for testability.
/// In production, pass [GoogleFonts.interTextTheme()] and
/// [GoogleFonts.inter(...)] respectively from main.dart.
ThemeData buildLightTheme({TextTheme? textTheme, TextStyle? titleTextStyle}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: OceanFlowColors.primary,
    brightness: Brightness.light,
    primary: OceanFlowColors.primary,
    onPrimary: OceanFlowColors.onPrimary,
    secondary: OceanFlowColors.accent,
    onSecondary: OceanFlowColors.onAccent,
    surface: OceanFlowColors.surface,
    error: OceanFlowColors.error,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: OceanFlowColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: OceanFlowColors.primary,
      foregroundColor: OceanFlowColors.onPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: titleTextStyle,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: OceanFlowColors.primary,
      foregroundColor: OceanFlowColors.onPrimary,
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OceanFlowColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OceanFlowColors.primary, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OceanFlowColors.primary,
        foregroundColor: OceanFlowColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}

/// Builds the Ocean Flow [ThemeData] for dark mode.
///
/// See [buildLightTheme] for parameter documentation.
ThemeData buildDarkTheme({TextTheme? textTheme, TextStyle? titleTextStyle}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: OceanFlowColors.primary,
    brightness: Brightness.dark,
    primary: OceanFlowColors.primaryLight,
    onPrimary: Colors.black,
    secondary: OceanFlowColors.accent,
    onSecondary: OceanFlowColors.onAccent,
    surface: OceanFlowColors.surfaceDark,
    error: OceanFlowColors.error,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: OceanFlowColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: OceanFlowColors.surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: titleTextStyle,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2C2C2C),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: OceanFlowColors.primaryLight,
      foregroundColor: Colors.black,
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OceanFlowColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: OceanFlowColors.primaryLight,
          width: 2,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OceanFlowColors.primaryLight,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}
