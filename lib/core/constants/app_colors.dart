import 'package:flutter/material.dart';

/// IndiRun V1 colour tokens — sourced from `IndiRun Foundations.svg`.
///
/// Do NOT use raw hex values in widgets. Always reference this class.
/// All colours are static const to ensure compile-time constants everywhere.
abstract final class AppColors {
  // ─────────────────────────────────────────────
  // Brand — Peacock Teal
  // ─────────────────────────────────────────────
  static const Color primary = Color(0xFF006874);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF97F0FF);
  static const Color onPrimaryContainer = Color(0xFF001F24);

  /// Lighter teal for interactive tonal elements
  static const Color primaryTonal = Color(0xFF4DB6C8);

  // ─────────────────────────────────────────────
  // Light mode surfaces
  // ─────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF3F8F8);
  static const Color surfaceContainerLight = Color(0xFFEBF1F1);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  // Dark mode surfaces
  // ─────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color surfaceDark = Color(0xFF1A1D23);
  static const Color surfaceContainerDark = Color(0xFF1F2425);
  static const Color surfaceElevatedDark = Color(0xFF2C3335);

  // ─────────────────────────────────────────────
  // Light mode text
  // ─────────────────────────────────────────────
  static const Color textLight = Color(0xFF191C1D);
  static const Color textSecondaryLight = Color(0xFF5D6B6E);
  static const Color textMutedLight = Color(0xFF5D6B6E);

  // ─────────────────────────────────────────────
  // Dark mode text
  // ─────────────────────────────────────────────
  static const Color textDark = Color(0xFFE0E3E3);
  static const Color textSecondaryDark = Color(0xFFA0ABAB);
  static const Color textMutedDark = Color(0xFF899395);

  // ─────────────────────────────────────────────
  // Borders / Outlines
  // ─────────────────────────────────────────────
  static const Color outlineLight = Color(0xFFC4D0D2);
  static const Color outlineDark = Color(0xFF2E3239);

  // ─────────────────────────────────────────────
  // Status colours (shared across themes)
  // ─────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE6F4E7);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color successContainerDark = Color(0xFF1B3A1C);

  static const Color warning = Color(0xFFB26A00);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color warningContainerDark = Color(0xFF3A2700);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFDECEA);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color errorContainerDark = Color(0xFF93000A);

  static const Color info = Color(0xFF1976D2);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF64B5F6);
  static const Color infoContainerDark = Color(0xFF0D2F4F);

  // ─────────────────────────────────────────────
  // Route polyline accent (magenta/fuchsia)
  // ─────────────────────────────────────────────
  static const Color routeAccent = Color(0xFFC2185B);

  // ─────────────────────────────────────────────
  // Map tokens
  // ─────────────────────────────────────────────
  static const Color mapLand = Color(0xFFDCEBE4);
  static const Color mapRoad = Color(0xFFFFFFFF);
  static const Color mapLandDark = Color(0xFF1E2E28);
  static const Color mapRoadDark = Color(0xFF2C3D36);

  // ─────────────────────────────────────────────
  // GPS blue dot
  // ─────────────────────────────────────────────
  static const Color gpsDot = Color(0xFF1976D2);
  static const Color gpsDotOuter = Color(0xFF90CAF9);

  // ─────────────────────────────────────────────
  // Semantic surface helpers (theme-adaptive)
  // ─────────────────────────────────────────────
  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? backgroundDark
          : backgroundLight;

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDark
          : surfaceLight;

  static Color outlineOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? outlineDark
          : outlineLight;

  static Color textOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textDark
          : textLight;

  static Color textMutedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textMutedDark
          : textMutedLight;

  // ─────────────────────────────────────────────
  // Backwards-compat aliases (keep compiling existing screens)
  // ─────────────────────────────────────────────
  static const Color background = backgroundLight;
  static const Color surfaceContainer = surfaceLight;
  static const Color surfaceContainerHigh = surfaceContainerLight;
  static const Color surfaceContainerLow = Color(0xFFF7FBFB);
  static const Color surfaceContainerDark2 = surfaceContainerDark;
  static const Color surfaceElevatedDark2 = surfaceElevatedDark;
  static const Color text = textLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color mutedText = textMutedLight;
  static const Color outline = outlineLight;
  static const Color borderDark = outlineDark;
  static const Color borderLight = outlineLight;
  static const Color primaryBright = Color(0xFF00838F);
  static const Color accent = success;
  static const Color accentWarning = warning;
  static const Color accentDanger = error;
  static const Color textPrimaryLight = textLight;
  static const Color textPrimaryDark = textDark;
  static const Color textSecondaryLight2 = textSecondaryLight;
  static const Color textMutedLight2 = textMutedLight;
  static const Color metricValue = textLight;
  static const Color metricLabel = textMutedLight;
  static const Color successContainer2 = successContainer;
}
