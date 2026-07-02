import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondary = brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return TextTheme(
      displayLarge: TextStyle(
        color: primary,
        fontSize: 42,
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: 0,
      ),
      displayMedium: TextStyle(
        color: primary,
        fontSize: 31,
        fontWeight: FontWeight.w900,
        height: 1.12,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        color: primary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.20,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.24,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.30,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0,
      ),
      bodyMedium: TextStyle(
        color: secondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0,
      ),
      labelLarge: TextStyle(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.20,
        letterSpacing: 0,
      ),
      labelMedium: TextStyle(
        color: secondary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
      ),
      labelSmall: TextStyle(
        color: secondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.20,
        letterSpacing: 0,
      ),
    );
  }
}
