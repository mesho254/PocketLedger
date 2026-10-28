import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(AppPalette.light);
  static ThemeData get darkTheme => _buildTheme(AppPalette.dark);

  static ThemeData _buildTheme(AppPalette p) {
    final baseTheme = p.isDark ? ThemeData.dark() : ThemeData.light();
    final textTheme = GoogleFonts.outfitTextTheme(baseTheme.textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: p.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: p.scaffoldBg,
      extensions: <ThemeExtension<dynamic>>[p],
      colorScheme: ColorScheme(
        brightness: p.isDark ? Brightness.dark : Brightness.light,
        primary: p.primaryBrand,
        onPrimary: Colors.white,
        secondary: p.secondaryTeal,
        onSecondary: Colors.white,
        error: p.expenseRose,
        onError: Colors.white,
        surface: p.cardSurface,
        onSurface: p.textPrimary,
      ),
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
          letterSpacing: -0.3,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: p.textPrimary,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: p.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: p.borderSubtle, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.nestedSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.primaryBrand, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.expenseRose),
        ),
        labelStyle: TextStyle(color: p.textSecondary),
        hintStyle: TextStyle(color: p.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primaryBrand,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: p.textPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}
