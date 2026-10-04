import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Semantic typography scale for IndiRun V1, sourced from `IndiRun Foundations.svg`.
///
/// Guidelines:
/// - **Poppins**: Major metrics, hero numbers, primary titles, section headlines.
/// - **Inter**: Body text, labels, buttons, metric captions, inputs.
abstract final class AppTextStyles {
  // ─────────────────────────────────────────────
  // Hero & Metrics (Poppins)
  // ─────────────────────────────────────────────

  /// Big hero metric number (e.g., active run distance 5.42 or 00:00:00 timer)
  static TextStyle displayHero({Color? color}) => GoogleFonts.poppins(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.1,
        color: color ?? AppColors.textLight,
      );

  /// Secondary metric number (e.g., pace 5'24", cadence 165)
  static TextStyle displayMetric({Color? color}) => GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: color ?? AppColors.textLight,
      );

  /// Card primary stat (e.g., 42.2 km, 3h 45m)
  static TextStyle displayCardStat({Color? color}) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: color ?? AppColors.textLight,
      );

  // ─────────────────────────────────────────────
  // Headlines (Poppins)
  // ─────────────────────────────────────────────

  static TextStyle headlineLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.25,
        color: color ?? AppColors.textLight,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.3,
        color: color ?? AppColors.textLight,
      );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.35,
        color: color ?? AppColors.textLight,
      );

  // ─────────────────────────────────────────────
  // Titles (Poppins)
  // ─────────────────────────────────────────────

  static TextStyle titleLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color ?? AppColors.textLight,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color ?? AppColors.textLight,
      );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color ?? AppColors.textLight,
      );

  // ─────────────────────────────────────────────
  // Body (Inter)
  // ─────────────────────────────────────────────

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textLight,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color ?? AppColors.textLight,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color ?? AppColors.textSecondaryLight,
      );

  // ─────────────────────────────────────────────
  // Buttons & Labels (Inter)
  // ─────────────────────────────────────────────

  static TextStyle buttonLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: color ?? Colors.white,
      );

  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color ?? AppColors.textLight,
      );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: color ?? AppColors.textLight,
      );

  /// Uppercase metric label (e.g. "DISTANCE", "AVG PACE", "ELEVATION")
  static TextStyle metricLabel({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        height: 1.2,
        color: color ?? AppColors.textMutedLight,
      );

  /// Metric unit attached to numbers (e.g., "km", "/km", "bpm", "kcal")
  static TextStyle metricUnit({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color ?? AppColors.textSecondaryLight,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: color ?? AppColors.textMutedLight,
      );

  // ─────────────────────────────────────────────
  // Theme-adaptive helpers
  // ─────────────────────────────────────────────
  static TextStyle displayHeroOf(BuildContext context) => displayHero(
        color: AppColors.textOf(context),
      );

  static TextStyle displayMetricOf(BuildContext context) => displayMetric(
        color: AppColors.textOf(context),
      );

  static TextStyle titleOf(BuildContext context) => titleLarge(
        color: AppColors.textOf(context),
      );

  static TextStyle bodyOf(BuildContext context) => bodyMedium(
        color: AppColors.textOf(context),
      );

  static TextStyle mutedOf(BuildContext context) => bodyMedium(
        color: AppColors.textMutedOf(context),
      );
}
