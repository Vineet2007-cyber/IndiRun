import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Standard IndiRun Card with 16dp rounded corners, semantic surface, and subtle border
class IndiRunCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  const IndiRunCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.surfaceContainerDark : AppColors.surfaceLight);
    final border = borderColor ??
        (isDark ? AppColors.outlineDark : AppColors.outlineLight);

    final cardContent = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPaddingLarge),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: border, width: AppDimensions.borderThin),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Run history item card displaying run summary
class RunHistoryCard extends StatelessWidget {
  final String title;
  final String date;
  final String distance;
  final String duration;
  final String pace;
  final String? calories;
  final VoidCallback? onTap;

  const RunHistoryCard({
    super.key,
    required this.title,
    required this.date,
    required this.distance,
    required this.duration,
    required this.pace,
    this.calories,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return IndiRunCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium(color: textColor),
              ),
              Text(
                date,
                style: AppTextStyles.caption(color: mutedColor),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: 'DISTANCE', value: distance),
              _StatItem(label: 'TIME', value: duration),
              _StatItem(label: 'PACE', value: pace),
              if (calories != null)
                _StatItem(label: 'CALORIES', value: calories!),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.titleSmall(color: textColor),
        ),
        const SizedBox(height: AppDimensions.space2),
        Text(
          label,
          style: AppTextStyles.caption(color: mutedColor).copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Metric summary card for weekly/monthly dashboards
class StatSummaryCard extends StatelessWidget {
  final String title;
  final String primaryValue;
  final String primaryUnit;
  final List<Widget> details;

  const StatSummaryCard({
    super.key,
    required this.title,
    required this.primaryValue,
    required this.primaryUnit,
    this.details = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return IndiRunCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.metricLabel(color: mutedColor),
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                primaryValue,
                style: AppTextStyles.displayCardStat(color: textColor),
              ),
              const SizedBox(width: AppDimensions.space4),
              Text(
                primaryUnit,
                style: AppTextStyles.metricUnit(color: mutedColor),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: details,
            ),
          ],
        ],
      ),
    );
  }
}
