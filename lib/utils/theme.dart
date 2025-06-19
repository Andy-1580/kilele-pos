import 'package:flutter/material.dart';

/// App color constants
class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF2196F3);
  static const Color tertiary = Color(0xFF64B5F6);
  static const Color quaternary = Color(0xFF90CAF9);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
}

/// Theme extensions for consistent styling
extension ThemeExtension on ThemeData {
  ColorScheme get colorScheme => ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      );

  TextTheme get textTheme => TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      );
}
