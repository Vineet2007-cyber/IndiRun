import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/locale_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Language selector right on onboarding screen as required by PRD
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space8),
            child: PopupMenuButton<AppLanguage>(
              tooltip: l10n.language,
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
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: const Icon(
                    Icons.directions_run_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Text(
                l10n.appTitle,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                l10n.welcomeToIndiRun,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    children: [
                      _buildFeatureBullet(
                        context,
                        icon: Icons.gps_fixed,
                        title: 'Accurate & Lightweight',
                        subtitle: 'Designed specifically for budget phones and Indian conditions.',
                      ),
                      const Divider(height: AppDimensions.space24),
                      _buildFeatureBullet(
                        context,
                        icon: Icons.offline_bolt_outlined,
                        title: 'Offline-First',
                        subtitle: 'Runs are always saved locally first; never lost due to network drop.',
                      ),
                      const Divider(height: AppDimensions.space24),
                      _buildFeatureBullet(
                        context,
                        icon: Icons.share_outlined,
                        title: 'WhatsApp & Instagram Visuals',
                        subtitle: 'Clean, beautiful run share cards in English, Hindi, and Gujarati.',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/auth'),
                child: Text(l10n.getStarted),
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
              const SizedBox(height: AppDimensions.space4),
              Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
