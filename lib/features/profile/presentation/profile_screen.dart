import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/locale_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.space16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text('Runner'),
                subtitle: const Text('IndiRun Runner • Tier 2/3 India'),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language / भाषा / ભાષા'),
                    subtitle: Text(AppLanguage.fromLocale(currentLocale).nativeLabel),
                    trailing: DropdownButton<AppLanguage>(
                      value: AppLanguage.fromLocale(currentLocale),
                      underline: const SizedBox.shrink(),
                      onChanged: (AppLanguage? newLang) {
                        if (newLang != null) {
                          ref.read(localeProvider.notifier).setLanguage(newLang);
                        }
                      },
                      items: AppLanguage.values.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang.nativeLabel),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l10n.settings),
                    subtitle: const Text('Units, auto-pause & voice cues (M1/M3)'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0 (M0 Foundation)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            OutlinedButton(
              onPressed: () => context.go('/onboarding'),
              child: const Text('View Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
