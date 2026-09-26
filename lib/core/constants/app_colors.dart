import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand Primary & Accents (High-visibility athletic colors)
  static const Color primary = Color(0xFFFF5722); // Vibrant Deep Orange / Saffron
  static const Color primaryBright = Color(0xFFFF7043);
  static const Color accent = Color(0xFF00E676); // High-contrast neon green for start / pace
  static const Color accentWarning = Color(0xFFFFD600); // Amber for paused / warning
  static const Color accentDanger = Color(0xFFFF1744); // Crimson for stop / discard

  // Dark Theme Surfaces (Sunlight readable with high contrast)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceElevatedDark = Color(0xFF2C2C2C);
  static const Color borderDark = Color(0xFF383838);

  // Light Theme Surfaces (Alternative high contrast for direct sunlight)
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF1F3F5);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textMutedDark = Color(0xFF757575);

  static const Color textPrimaryLight = Color(0xFF111111);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color textMutedLight = Color(0xFF888888);

  // Metric Display
  static const Color metricValue = Color(0xFFFFFFFF);
  static const Color metricLabel = Color(0xFFA0A0A0);
}
