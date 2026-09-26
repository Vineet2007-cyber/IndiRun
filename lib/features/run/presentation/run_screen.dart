import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/widgets/metric_display.dart';

class RunScreen extends StatelessWidget {
  const RunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.run),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Active Run Tracking Screen',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'Tracking engine, foreground service & GPS stream will be integrated in M2/M3.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MetricDisplay(
                    label: l10n.distance,
                    value: '0.00',
                    unit: 'km',
                  ),
                  MetricDisplay(
                    label: l10n.duration,
                    value: '00:00',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space32),
              MetricDisplay(
                crossAxisAlignment: CrossAxisAlignment.center,
                label: l10n.pace,
                value: '--:--',
                unit: '/km',
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () => context.push('/share'),
                icon: const Icon(Icons.share),
                label: Text('${l10n.share} (Preview Screen)'),
              ),
              const SizedBox(height: AppDimensions.space12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
