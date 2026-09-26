import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/widgets/metric_display.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/application/profile_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);
    final authState = ref.watch(authControllerProvider);
    final profileAsync = ref.watch(profileControllerProvider);
    final displayName = profileAsync.value?.displayName ?? authState.user?.displayName ?? 'Runner';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        actions: [
          // Language selector dropdown to test live localization
          PopupMenuButton<AppLanguage>(
            tooltip: 'Select Language',
            icon: const Icon(Icons.language),
            initialValue: AppLanguage.fromLocale(currentLocale),
            onSelected: (language) {
              ref.read(localeProvider.notifier).setLanguage(language);
            },
            itemBuilder: (context) {
              return AppLanguage.values.map((lang) {
                return PopupMenuItem(
                  value: lang,
                  child: Text('${lang.nativeLabel} (${lang.label})'),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.profile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
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
                        '${l10n.welcomeToIndiRun}, $displayName',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          MetricDisplay(
                            label: l10n.avgPace,
                            value: '--:--',
                            unit: '/km',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => context.push('/run'),
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(
                  l10n.startRun,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: AppDimensions.space12),
              OutlinedButton.icon(
                onPressed: () => context.push('/history'),
                icon: const Icon(Icons.history_rounded),
                label: Text(l10n.history),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
