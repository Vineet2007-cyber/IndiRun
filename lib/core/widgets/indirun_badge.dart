import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// GPS accuracy states
enum GpsAccuracyState { searching, strong, weak, lost }

/// GPS Status Indicator pill badge
class GpsStatusIndicator extends StatelessWidget {
  final GpsAccuracyState state;
  final String? customLabel;

  const GpsStatusIndicator({super.key, required this.state, this.customLabel});

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color bgColor;
    Color textColor;
    String label;

    switch (state) {
      case GpsAccuracyState.strong:
        dotColor = AppColors.success;
        bgColor = AppColors.successContainer;
        textColor = AppColors.success;
        label = 'GPS Ready';
        break;
      case GpsAccuracyState.weak:
        dotColor = AppColors.warning;
        bgColor = AppColors.warningContainer;
        textColor = AppColors.warning;
        label = 'Weak GPS';
        break;
      case GpsAccuracyState.searching:
        dotColor = AppColors.primary;
        bgColor = AppColors.primaryContainer;
        textColor = AppColors.onPrimaryContainer;
        label = 'Searching GPS...';
        break;
      case GpsAccuracyState.lost:
        dotColor = AppColors.error;
        bgColor = AppColors.errorContainer;
        textColor = AppColors.error;
        label = 'GPS Lost';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.chipPaddingH,
        vertical: AppDimensions.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.space6),
          Text(
            customLabel ?? label,
            style: AppTextStyles.caption(color: textColor)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Run state pill badge (Active, Paused, Completed)
enum RunStatus { active, paused, completed }

class RunStatusBadge extends StatelessWidget {
  final RunStatus status;

  const RunStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case RunStatus.active:
        bgColor = AppColors.primaryContainer;
        textColor = AppColors.onPrimaryContainer;
        label = 'ACTIVE';
        break;
      case RunStatus.paused:
        bgColor = AppColors.warningContainer;
        textColor = AppColors.warning;
        label = 'PAUSED';
        break;
      case RunStatus.completed:
        bgColor = AppColors.successContainer;
        textColor = AppColors.success;
        label = 'COMPLETED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space10,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: textColor)
            .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
      ),
    );
  }
}

/// Split time row for kilometer split breakdown
class SplitTimeRow extends StatelessWidget {
  final int kilometer;
  final String pace;
  final String? delta;
  final bool isFaster;

  const SplitTimeRow({
    super.key,
    required this.kilometer,
    required this.pace,
    this.delta,
    this.isFaster = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceContainerDark
                      : AppColors.surfaceContainerLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$kilometer',
                  style: AppTextStyles.labelMedium(color: textColor)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Text(
                'KM $kilometer',
                style: AppTextStyles.bodyMedium(color: textColor)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: [
              Text(pace, style: AppTextStyles.titleSmall(color: textColor)),
              if (delta != null) ...[
                const SizedBox(width: AppDimensions.space8),
                Text(
                  delta!,
                  style: AppTextStyles.caption(
                    color: isFaster ? AppColors.success : AppColors.warning,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Audio cue chip toggle
class AudioCueChip extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;

  const AudioCueChip({super.key, required this.isEnabled, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      avatar: Icon(
        isEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        size: 16,
        color: isEnabled
            ? AppColors.primary
            : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
      ),
      label: Text(
        isEnabled ? 'Audio Cues On' : 'Audio Cues Off',
        style: AppTextStyles.caption(
          color: isEnabled
              ? AppColors.primary
              : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
        ).copyWith(fontWeight: FontWeight.w600),
      ),
      backgroundColor: isEnabled
          ? AppColors.primaryContainer.withValues(alpha: 0.3)
          : (isDark ? AppColors.surfaceContainerDark : AppColors.surfaceLight),
      shape: const StadiumBorder(),
      side: BorderSide(
        color: isEnabled
            ? AppColors.primary
            : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      onPressed: () => onToggle?.call(!isEnabled),
    );
  }
}
