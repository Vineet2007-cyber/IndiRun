import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/indirun_badge.dart';
import '../../../core/widgets/indirun_banner.dart';
import '../../../core/widgets/indirun_button.dart';
import '../../../core/widgets/indirun_card.dart';
import '../../../core/widgets/indirun_text_field.dart';
import '../../../core/widgets/metric_display.dart';

/// Developer-only Design System Preview Screen.
///
/// Visual reference verifying all tokens from `IndiRun Foundations.svg`:
/// - Colors (Peacock Teal palette, dark/light surfaces, status, route polyline)
/// - Typography (Poppins display/metrics/titles & Inter body/labels)
/// - Buttons & Run Controls (Primary, Outlined, Tonal, Destructive, Circular Controls)
/// - Metrics & Timers (Hero numbers, tabular digital timer, stat tiles)
/// - Badges & Banners (GPS pills, run status badges, system banners)
/// - Cards (Run history, stat summary, split times)
/// - Form Elements (Inputs, states, validation)
class DsPreviewScreen extends ConsumerStatefulWidget {
  const DsPreviewScreen({super.key});

  @override
  ConsumerState<DsPreviewScreen> createState() => _DsPreviewScreenState();
}

class _DsPreviewScreenState extends ConsumerState<DsPreviewScreen> {
  bool _audioCuesEnabled = true;

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IndiRun Design System'),
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: Icon(
              currentThemeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : currentThemeMode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded,
            ),
            tooltip: 'Switch Theme',
            onSelected: (mode) {
              ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(Icons.brightness_auto_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('System'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Light'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Dark'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadding,
          vertical: AppDimensions.space16,
        ),
        children: [
          _buildSectionHeader('1. COLOR PALETTE (Peacock Teal System)'),
          const SizedBox(height: AppDimensions.space12),
          _buildColorPalette(isDark),

          const SizedBox(height: AppDimensions.space32),
          _buildSectionHeader('2. TYPOGRAPHY HIERARCHY'),
          const SizedBox(height: AppDimensions.space12),
          _buildTypographySection(isDark),

          const SizedBox(height: AppDimensions.space32),
          _buildSectionHeader('3. BUTTONS & RUN CONTROLS'),
          const SizedBox(height: AppDimensions.space12),
          _buildButtonsSection(isDark),

          const SizedBox(height: AppDimensions.space32),
          _buildSectionHeader('4. METRIC DISPLAYS & BIG TIMER'),
          const SizedBox(height: AppDimensions.space12),
          _buildMetricsSection(isDark),

          const SizedBox(height: AppDimensions.space32),
          _buildSectionHeader('5. BADGES, GPS & STATUS PILLS'),
          const SizedBox(height: AppDimensions.space12),
          _buildBadgesSection(),

          const SizedBox(height: AppDimensions.space32),
          _buildSectionHeader('6. CARDS & SPLITS'),
          const SizedBox(height: AppDimensions.space12),
          _buildCardsSection(),

          const SizedBox(height: AppDimensions.space32),
          _buildSectionHeader('7. FORM FIELDS'),
          const SizedBox(height: AppDimensions.space12),
          _buildFormSection(),

          const SizedBox(height: AppDimensions.space32),
          _buildSectionHeader('8. STATUS BANNERS'),
          const SizedBox(height: AppDimensions.space12),
          _buildBannersSection(),

          const SizedBox(height: AppDimensions.space48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: Text(
        title,
        style: AppTextStyles.titleMedium().copyWith(
          color: AppColors.primary,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildColorPalette(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ColorChip(
                name: 'Primary',
                hex: '#006874',
                color: AppColors.primary,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: _ColorChip(
                name: 'Container',
                hex: '#97F0FF',
                color: AppColors.primaryContainer,
                textColor: AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: _ColorChip(
                name: 'Tonal',
                hex: '#4DB6C8',
                color: AppColors.primaryTonal,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        Row(
          children: [
            Expanded(
              child: _ColorChip(
                name: isDark ? 'Dark Surface' : 'Light Surface',
                hex: isDark ? '#1A1D23' : '#F3F8F8',
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                textColor: isDark ? AppColors.textDark : AppColors.textLight,
                hasBorder: true,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: _ColorChip(
                name: isDark ? 'Dark Outline' : 'Light Outline',
                hex: isDark ? '#2E3239' : '#C4D0D2',
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                textColor: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: _ColorChip(
                name: 'Route Polyline',
                hex: '#C2185B',
                color: AppColors.routeAccent,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        Row(
          children: [
            Expanded(
              child: _ColorChip(
                name: 'Success',
                hex: '#2E7D32',
                color: AppColors.success,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: _ColorChip(
                name: 'Warning',
                hex: '#B26A00',
                color: AppColors.warning,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: _ColorChip(
                name: 'Error',
                hex: '#BA1A1A',
                color: AppColors.error,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: _ColorChip(
                name: 'Info',
                hex: '#1976D2',
                color: AppColors.info,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypographySection(bool isDark) {
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Hero (Poppins 56 w800)',
          style: AppTextStyles.caption(color: mutedColor),
        ),
        Text('5.42 km', style: AppTextStyles.displayHero(color: textColor)),
        const SizedBox(height: AppDimensions.space12),
        Text(
          'Display Metric (Poppins 36 w700)',
          style: AppTextStyles.caption(color: mutedColor),
        ),
        Text('00:28:45', style: AppTextStyles.displayMetric(color: textColor)),
        const SizedBox(height: AppDimensions.space12),
        Text(
          'Headline Large (Poppins 28 w700)',
          style: AppTextStyles.caption(color: mutedColor),
        ),
        Text('Morning Interval Run', style: AppTextStyles.headlineLarge(color: textColor)),
        const SizedBox(height: AppDimensions.space12),
        Text(
          'Title Large (Poppins 20 w600)',
          style: AppTextStyles.caption(color: mutedColor),
        ),
        Text('Weekly Mileage Target', style: AppTextStyles.titleLarge(color: textColor)),
        const SizedBox(height: AppDimensions.space12),
        Text(
          'Body Large & Medium (Inter 16 / 14 w400)',
          style: AppTextStyles.caption(color: mutedColor),
        ),
        Text(
          'IndiRun tracks your route with high precision GPS and provides real-time split audio coaching.',
          style: AppTextStyles.bodyMedium(color: textColor),
        ),
        const SizedBox(height: AppDimensions.space12),
        Text(
          'Metric Label (Inter 12 w600 uppercase)',
          style: AppTextStyles.caption(color: mutedColor),
        ),
        Text('AVERAGE PACE • CADENCE • ELEVATION GAIN', style: AppTextStyles.metricLabel(color: mutedColor)),
      ],
    );
  }

  Widget _buildButtonsSection(bool isDark) {
    return Column(
      children: [
        IndiRunButton(
          label: 'Primary CTA Button',
          onPressed: () {},
          variant: IndiRunButtonVariant.primary,
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        ),
        const SizedBox(height: AppDimensions.space10),
        IndiRunButton(
          label: 'Outlined Button',
          onPressed: () {},
          variant: IndiRunButtonVariant.outlined,
        ),
        const SizedBox(height: AppDimensions.space10),
        IndiRunButton(
          label: 'Tonal Button',
          onPressed: () {},
          variant: IndiRunButtonVariant.tonal,
        ),
        const SizedBox(height: AppDimensions.space10),
        IndiRunButton(
          label: 'Destructive Button',
          onPressed: () {},
          variant: IndiRunButtonVariant.destructive,
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        const SizedBox(height: AppDimensions.space10),
        const IndiRunButton(
          label: 'Disabled Button',
          onPressed: null,
          variant: IndiRunButtonVariant.disabled,
        ),
        const SizedBox(height: AppDimensions.space10),
        IndiRunButton(
          label: 'Loading Button',
          onPressed: () {},
          isLoading: true,
        ),
        const SizedBox(height: AppDimensions.space20),
        Text(
          'Circular Run Tracking Controls',
          style: AppTextStyles.titleSmall(),
        ),
        const SizedBox(height: AppDimensions.space12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IndiRunControlButton(
              variant: IndiRunControlVariant.start,
              size: 64,
              label: 'START',
              onPressed: () {},
            ),
            IndiRunControlButton(
              variant: IndiRunControlVariant.pause,
              size: 64,
              label: 'PAUSE',
              onPressed: () {},
            ),
            IndiRunControlButton(
              variant: IndiRunControlVariant.resume,
              size: 64,
              label: 'RESUME',
              onPressed: () {},
            ),
            IndiRunControlButton(
              variant: IndiRunControlVariant.stop,
              size: 64,
              label: 'STOP',
              onPressed: () {},
            ),
            IndiRunControlButton(
              variant: IndiRunControlVariant.lock,
              size: 52,
              label: 'LOCK',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsSection(bool isDark) {
    return Column(
      children: [
        const HeroMetricDisplay(
          value: '8.45',
          unit: 'KM',
          label: 'TOTAL DISTANCE',
        ),
        const SizedBox(height: AppDimensions.space16),
        const BigMetricTimer(
          duration: Duration(hours: 0, minutes: 42, seconds: 18),
        ),
        const SizedBox(height: AppDimensions.space20),
        IndiRunCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              MetricDisplay(label: 'PACE', value: '5\'12"', unit: '/km'),
              MetricDisplay(label: 'CALORIES', value: '542', unit: 'kcal'),
              MetricDisplay(label: 'CADENCE', value: '168', unit: 'spm'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GPS Accuracy States', style: AppTextStyles.titleSmall()),
        const SizedBox(height: AppDimensions.space8),
        const Wrap(
          spacing: AppDimensions.space8,
          runSpacing: AppDimensions.space8,
          children: [
            GpsStatusIndicator(state: GpsAccuracyState.strong),
            GpsStatusIndicator(state: GpsAccuracyState.searching),
            GpsStatusIndicator(state: GpsAccuracyState.weak),
            GpsStatusIndicator(state: GpsAccuracyState.lost),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),
        Text('Run Status Badges', style: AppTextStyles.titleSmall()),
        const SizedBox(height: AppDimensions.space8),
        const Wrap(
          spacing: AppDimensions.space8,
          runSpacing: AppDimensions.space8,
          children: [
            RunStatusBadge(status: RunStatus.active),
            RunStatusBadge(status: RunStatus.paused),
            RunStatusBadge(status: RunStatus.completed),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),
        Text('Audio Cue Toggle', style: AppTextStyles.titleSmall()),
        const SizedBox(height: AppDimensions.space8),
        AudioCueChip(
          isEnabled: _audioCuesEnabled,
          onToggle: (v) => setState(() => _audioCuesEnabled = v),
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      children: [
        const StatSummaryCard(
          title: 'This Week',
          primaryValue: '28.6',
          primaryUnit: 'km',
          details: [
            MetricDisplay(label: 'RUNS', value: '4'),
            MetricDisplay(label: 'TIME', value: '2h 35m'),
            MetricDisplay(label: 'AVG PACE', value: '5\'24"'),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),
        RunHistoryCard(
          title: 'Morning Park Loop',
          date: 'Today, 6:30 AM',
          distance: '6.20 km',
          duration: '32:15',
          pace: '5\'12" /km',
          calories: '412 kcal',
          onTap: () {},
        ),
        const SizedBox(height: AppDimensions.space12),
        IndiRunCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kilometer Splits',
                style: AppTextStyles.titleSmall(),
              ),
              const SizedBox(height: AppDimensions.space8),
              const SplitTimeRow(kilometer: 1, pace: '5\'20"', delta: '-0:12', isFaster: true),
              const Divider(height: 1),
              const SplitTimeRow(kilometer: 2, pace: '5\'14"', delta: '-0:06', isFaster: true),
              const Divider(height: 1),
              const SplitTimeRow(kilometer: 3, pace: '5\'28"', delta: '+0:08', isFaster: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        const IndiRunTextField(
          labelText: 'Full Name',
          hintText: 'Enter your name',
          prefixIcon: Icon(Icons.person_outline_rounded),
        ),
        const SizedBox(height: AppDimensions.space12),
        const IndiRunTextField(
          labelText: 'Password',
          hintText: 'Enter secure password',
          isPassword: true,
          prefixIcon: Icon(Icons.lock_outline_rounded),
        ),
        const SizedBox(height: AppDimensions.space12),
        const IndiRunTextField(
          labelText: 'Validated Username',
          hintText: 'runner_pro',
          isSuccess: true,
          prefixIcon: Icon(Icons.alternate_email_rounded),
          helperText: 'Username is available',
          helperColor: AppColors.success,
        ),
        const SizedBox(height: AppDimensions.space12),
        const IndiRunTextField(
          labelText: 'Email Address',
          hintText: 'invalid-email',
          errorText: 'Please enter a valid email address',
          prefixIcon: Icon(Icons.email_outlined),
        ),
      ],
    );
  }

  Widget _buildBannersSection() {
    return Column(
      children: [
        const IndiRunBanner(
          message: 'GPS signal ready • Accuracy 4 meters',
          type: IndiRunBannerType.gpsReady,
          leading: Icon(Icons.gps_fixed_rounded, color: AppColors.success, size: 20),
        ),
        const SizedBox(height: AppDimensions.space8),
        const IndiRunBanner(
          message: 'Acquiring satellite fix... Move to an open area',
          type: IndiRunBannerType.searchingGps,
          leading: Icon(Icons.gps_not_fixed_rounded, color: AppColors.warning, size: 20),
        ),
        const SizedBox(height: AppDimensions.space8),
        const IndiRunBanner(
          message: 'GPS is disabled. Turn on location services to track run.',
          type: IndiRunBannerType.gpsOff,
          leading: Icon(Icons.location_off_rounded, color: AppColors.error, size: 20),
        ),
      ],
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String name;
  final String hex;
  final Color color;
  final Color textColor;
  final bool hasBorder;

  const _ColorChip({
    required this.name,
    required this.hex,
    required this.color,
    required this.textColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(AppDimensions.space8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: hasBorder
            ? Border.all(color: AppColors.outlineOf(context), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: AppTextStyles.caption(color: textColor).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            hex,
            style: AppTextStyles.caption(color: textColor.withValues(alpha: 0.8)).copyWith(
              fontSize: 9,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
