import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/domain/user_profile.dart';
import '../../../core/theme/theme_provider.dart';

/// S25 Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(profileControllerProvider);
    final units = profileAsync.value?.units ?? DistanceUnit.kilometers;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Settings',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),
                  // APPEARANCE
                  _SectionLabel('APPEARANCE'),
                  const SizedBox(height: 8),
                  // Theme segmented button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outline),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        _ThemeOption('Light', themeMode == ThemeMode.light, () {
                          ref.read(themeModeProvider.notifier).setMode(ThemeMode.light);
                        }),
                        _ThemeOption('Dark', themeMode == ThemeMode.dark, () {
                          ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
                        }),
                        _ThemeOption('System', themeMode == ThemeMode.system, () {
                          ref.read(themeModeProvider.notifier).setMode(ThemeMode.system);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // VOICE-CUES
                  _SectionLabel('VOICE-CUES'),
                  _SettingsTile(
                    title: 'Turn on by default',
                    trailing: Switch(
                      value: false,
                      onChanged: null,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  _SettingsTile(
                    title: 'Test voice',
                    trailing: const Icon(Icons.play_arrow_rounded,
                        color: AppColors.textSecondary, size: 18),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  // UNITS
                  _SectionLabel('UNITS'),
                  _SettingsTile(
                    title: 'Distance',
                    trailing: Text(
                      units == DistanceUnit.kilometers ? 'Kilometres' : 'Miles',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    onTap: () => _showUnitsDialog(context, ref, units),
                  ),
                  const SizedBox(height: 8),
                  // PERMISSIONS
                  _SectionLabel('PERMISSIONS'),
                  _SettingsTile(
                    title: 'Location',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('While using app',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                    onTap: () {},
                  ),
                  _SettingsTile(
                    title: 'Notifications',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('On',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  // ACCOUNT
                  _SectionLabel('ACCOUNT'),
                  _SettingsTile(
                    title: 'Change password',
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 18),
                    onTap: () {},
                  ),
                  _SettingsTile(
                    title: 'Logout',
                    titleColor: AppColors.error,
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                  ),
                  const SizedBox(height: 8),
                  // ABOUT
                  _SectionLabel('ABOUT'),
                  _SettingsTile(
                    title: 'App version',
                    trailing: Text('1.0.0',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  ),
                  _SettingsTile(
                    title: 'Terms and Privacy Policy',
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 18),
                    onTap: () {},
                  ),
                  _SettingsTile(
                    title: 'Send feedback',
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 18),
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, WidgetRef ref, DistanceUnit current) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Distance unit'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(profileControllerProvider.notifier).updateUnits(DistanceUnit.kilometers);
              Navigator.pop(context);
            },
            child: const Text('Kilometres'),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(profileControllerProvider.notifier).updateUnits(DistanceUnit.miles);
              Navigator.pop(context);
            },
            child: const Text('Miles'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: titleColor ?? AppColors.text,
                    ),
              ),
            ),
            // ignore: use_null_aware_elements — Widget? can't be used with ? in List<Widget>
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption(this.label, this.selected, this.onTap);
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.normal,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
