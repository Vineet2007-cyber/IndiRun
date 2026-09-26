import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/locale_provider.dart';

class RunDetailScreen extends StatelessWidget {
  final String runId;

  const RunDetailScreen({
    super.key,
    required this.runId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.run} Detail'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Run ID: $runId',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      const Text(
                        'Detailed splits, route map and post-run summary placeholder.',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.push('/share'),
                icon: const Icon(Icons.share),
                label: Text(l10n.share),
              ),
              const SizedBox(height: AppDimensions.space12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
