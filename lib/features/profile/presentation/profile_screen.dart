import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/locale_provider.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';
import '../domain/user_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _showEditDisplayNameDialog(String currentName) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.editProfile),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.displayName,
                hintText: l10n.enterDisplayName,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.displayNameRequired;
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(ctx).pop(true);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (updated == true && mounted) {
      final success = await ref
          .read(profileControllerProvider.notifier)
          .updateDisplayName(controller.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.saved : l10n.somethingWentWrong),
          backgroundColor: success ? AppColors.accent : AppColors.accentDanger,
        ),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.deleteAccountConfirmTitle),
          content: Text(l10n.deleteAccountConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentDanger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.deleteAccount),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await ref.read(authControllerProvider.notifier).deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);
    final profileAsync = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    final profile = profileAsync.value;
    final displayName = profile?.displayName ?? authState.user?.displayName ?? 'Runner';
    final email = profile?.email ?? authState.user?.email ?? '';
    final units = profile?.units ?? DistanceUnit.kilometers;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.space16),
          children: [
            // User Identity Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary,
                      backgroundImage: profile?.avatarUrl != null
                          ? NetworkImage(profile!.avatarUrl!)
                          : null,
                      child: profile?.avatarUrl == null
                          ? Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'R',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.space4),
                            Text(
                              email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: l10n.editProfile,
                      onPressed: () => _showEditDisplayNameDialog(displayName),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // Settings & Preferences Section
            Text(
              l10n.settings.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: AppDimensions.space8),
            Card(
              child: Column(
                children: [
                  // Language Selection
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.language),
                    subtitle: Text(AppLanguage.fromLocale(currentLocale).nativeLabel),
                    trailing: DropdownButton<AppLanguage>(
                      value: AppLanguage.fromLocale(currentLocale),
                      underline: const SizedBox.shrink(),
                      onChanged: (AppLanguage? newLang) {
                        if (newLang != null) {
                          ref.read(localeProvider.notifier).setLanguage(newLang);
                          ref
                              .read(profileControllerProvider.notifier)
                              .updateLanguage(newLang.locale.languageCode);
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

                  // Units Selection (Kilometers vs Miles)
                  ListTile(
                    leading: const Icon(Icons.straighten),
                    title: Text(l10n.units),
                    subtitle: Text(
                      units == DistanceUnit.kilometers ? l10n.kilometers : l10n.miles,
                    ),
                    trailing: SegmentedButton<DistanceUnit>(
                      segments: [
                        ButtonSegment(
                          value: DistanceUnit.kilometers,
                          label: Text(l10n.kilometers.substring(0, 2).toUpperCase()),
                        ),
                        ButtonSegment(
                          value: DistanceUnit.miles,
                          label: Text(l10n.miles.substring(0, 2).toUpperCase()),
                        ),
                      ],
                      selected: {units},
                      onSelectionChanged: (newSelection) {
                        ref
                            .read(profileControllerProvider.notifier)
                            .updateUnits(newSelection.first);
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Voice Cues (M3 Placeholder)
                  ListTile(
                    leading: const Icon(Icons.volume_up_outlined),
                    title: Text(l10n.voiceCues),
                    subtitle: Text(l10n.comingSoon),
                    trailing: Switch(
                      value: false,
                      onChanged: null, // Disabled per M1 rules
                    ),
                  ),
                  const Divider(height: 1),

                  // Auto-Pause (M3 Placeholder)
                  ListTile(
                    leading: const Icon(Icons.pause_circle_outline),
                    title: Text(l10n.autoPause),
                    subtitle: Text(l10n.comingSoon),
                    trailing: Switch(
                      value: false,
                      onChanged: null, // Disabled per M1 rules
                    ),
                  ),
                  const Divider(height: 1),

                  // Battery Guidance (M2 Placeholder)
                  ListTile(
                    leading: const Icon(Icons.battery_saver),
                    title: Text(l10n.batteryGuidance),
                    subtitle: Text(l10n.comingSoon),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: null, // Disabled per M1 rules
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // About & Legal
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.policy_outlined),
                    title: Text(l10n.privacyPolicy),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.privacyPolicy),
                          content: const Text(
                            'IndiRun is designed with privacy by default. We do not sell or track your personal location data.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(l10n.termsOfService),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.termsOfService),
                          content: const Text('IndiRun Terms of Service V1.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.appVersion),
                    subtitle: const Text('1.0.0 (M1 Authentication & Profile)'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space24),

            // Sign Out Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevatedDark,
                foregroundColor: AppColors.textPrimaryDark,
                side: const BorderSide(color: AppColors.borderDark),
              ),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.signOut),
            ),

            const SizedBox(height: AppDimensions.space12),

            // Delete Account Button
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentDanger,
              ),
              onPressed: () => _confirmDeleteAccount(),
              icon: const Icon(Icons.delete_forever),
              label: Text(l10n.deleteAccount),
            ),

            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      ),
    );
  }
}
