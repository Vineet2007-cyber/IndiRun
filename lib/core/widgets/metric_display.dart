import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

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
    final effectiveValueStyle = valueStyle ?? theme.textTheme.displayMedium;
    final effectiveLabelStyle = labelStyle ?? theme.textTheme.labelSmall;

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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
