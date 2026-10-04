import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum IndiRunButtonVariant {
  primary,
  outlined,
  tonal,
  text,
  destructive,
  disabled,
}

class IndiRunButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IndiRunButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isLoading;

  const IndiRunButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = IndiRunButtonVariant.primary,
    this.icon,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (variant == IndiRunButtonVariant.disabled || onPressed == null) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            disabledBackgroundColor: isDark ? AppColors.outlineDark : AppColors.outline,
            disabledForegroundColor: isDark ? AppColors.textMutedDark : AppColors.mutedText,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: _buildChild(isDark ? AppColors.textMutedDark : AppColors.mutedText),
        ),
      );
    }

    switch (variant) {
      case IndiRunButtonVariant.primary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: _buildChild(Colors.white),
          ),
        );

      case IndiRunButtonVariant.outlined:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.primaryContainer : AppColors.primary,
              side: BorderSide(
                color: isDark ? AppColors.primaryContainer : AppColors.primary,
                width: 1.5,
              ),
              shape: const StadiumBorder(),
            ),
            child: _buildChild(isDark ? AppColors.primaryContainer : AppColors.primary),
          ),
        );

      case IndiRunButtonVariant.tonal:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: _buildChild(AppColors.onPrimaryContainer),
          ),
        );

      case IndiRunButtonVariant.destructive:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: _buildChild(Colors.white),
          ),
        );

      case IndiRunButtonVariant.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.primaryContainer : AppColors.primary,
              shape: const StadiumBorder(),
            ),
            child: _buildChild(isDark ? AppColors.primaryContainer : AppColors.primary),
          ),
        );

      case IndiRunButtonVariant.disabled:
        return const SizedBox.shrink();
    }
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Control action variants for active run screen controls
enum IndiRunControlVariant {
  start,
  pause,
  resume,
  stop,
  lock,
  unlock,
}

/// Circular action button designed for run tracking controls (Start, Pause, Resume, Stop)
class IndiRunControlButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IndiRunControlVariant variant;
  final double size;
  final String? label;
  final Widget? icon;

  const IndiRunControlButton({
    super.key,
    required this.onPressed,
    required this.variant,
    this.size = AppDimensions.runActionButtonSize,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    IconData defaultIcon;

    switch (variant) {
      case IndiRunControlVariant.start:
      case IndiRunControlVariant.resume:
        backgroundColor = AppColors.primary;
        iconColor = Colors.white;
        defaultIcon = Icons.play_arrow_rounded;
        break;
      case IndiRunControlVariant.pause:
        backgroundColor = AppColors.warning;
        iconColor = Colors.white;
        defaultIcon = Icons.pause_rounded;
        break;
      case IndiRunControlVariant.stop:
        backgroundColor = AppColors.error;
        iconColor = Colors.white;
        defaultIcon = Icons.stop_rounded;
        break;
      case IndiRunControlVariant.lock:
        backgroundColor = Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceContainerDark
            : AppColors.surfaceContainerLight;
        iconColor = Theme.of(context).brightness == Brightness.dark
            ? AppColors.textDark
            : AppColors.textLight;
        defaultIcon = Icons.lock_outline_rounded;
        break;
      case IndiRunControlVariant.unlock:
        backgroundColor = AppColors.primaryContainer;
        iconColor = AppColors.onPrimaryContainer;
        defaultIcon = Icons.lock_open_rounded;
        break;
    }

    Widget button = SizedBox(
      width: size,
      height: size,
      child: RawMaterialButton(
        onPressed: onPressed,
        elevation: AppDimensions.elevationMedium,
        fillColor: backgroundColor,
        shape: const CircleBorder(),
        constraints: BoxConstraints.tightFor(width: size, height: size),
        child: icon ?? Icon(defaultIcon, color: iconColor, size: size * 0.48),
      ),
    );

    if (label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          const SizedBox(height: AppDimensions.space6),
          Text(
            label!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    }

    return button;
  }
}

