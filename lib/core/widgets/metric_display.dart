import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Standard metric display widget (e.g., Pace, Calories, Cadence)
class MetricDisplay extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final CrossAxisAlignment crossAxisAlignment;

  const MetricDisplay({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueStyle,
    this.labelStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveValueStyle = valueStyle ??
        AppTextStyles.displayMetric(
          color: theme.brightness == Brightness.dark
              ? AppColors.textDark
              : AppColors.textLight,
        );
    final effectiveLabelStyle = labelStyle ??
        AppTextStyles.metricLabel(
          color: theme.brightness == Brightness.dark
              ? AppColors.textMutedDark
              : AppColors.textMutedLight,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: effectiveValueStyle,
            ),
            if (unit != null) ...[
              const SizedBox(width: AppDimensions.space4),
              Text(
                unit!,
                style: AppTextStyles.metricUnit(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          label.toUpperCase(),
          style: effectiveLabelStyle,
        ),
      ],
    );
  }
}

/// Large hero metric display (e.g. 5.42 km on the active run screen)
class HeroMetricDisplay extends StatelessWidget {
  final String value;
  final String unit;
  final String? label;
  final CrossAxisAlignment crossAxisAlignment;

  const HeroMetricDisplay({
    super.key,
    required this.value,
    required this.unit,
    this.label,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTextStyles.displayHero(color: textColor),
            ),
            const SizedBox(width: AppDimensions.space8),
            Text(
              unit,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
            ),
          ],
        ),
        if (label != null) ...[
          const SizedBox(height: AppDimensions.space4),
          Text(
            label!.toUpperCase(),
            style: AppTextStyles.metricLabel(color: mutedColor),
          ),
        ],
      ],
    );
  }
}

/// Big digital running timer displaying hh:mm:ss or mm:ss with tabular figures
class BigMetricTimer extends StatelessWidget {
  final Duration duration;
  final String? label;
  final TextStyle? style;
  final bool showHours;

  const BigMetricTimer({
    super.key,
    required this.duration,
    this.label = 'DURATION',
    this.style,
    this.showHours = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final String formattedTime;
    if (showHours || hours > 0) {
      formattedTime =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      formattedTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    final timerStyle = (style ?? AppTextStyles.displayHero(color: textColor)).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedTime,
          style: timerStyle,
        ),
        if (label != null) ...[
          const SizedBox(height: AppDimensions.space4),
          Text(
            label!.toUpperCase(),
            style: AppTextStyles.metricLabel(color: mutedColor),
          ),
        ],
      ],
    );
  }
}
