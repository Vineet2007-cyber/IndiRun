import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indirun/core/constants/app_colors.dart';
import 'package:indirun/core/constants/app_dimensions.dart';
import 'package:indirun/core/theme/app_text_styles.dart';
import 'package:indirun/core/theme/app_theme.dart';
import 'package:indirun/core/widgets/indirun_badge.dart';
import 'package:indirun/core/widgets/indirun_button.dart';
import 'package:indirun/core/widgets/metric_display.dart';
import 'package:indirun/features/dev/presentation/ds_preview_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('IndiRun Design System Tokens', () {
    test('AppColors verifies Peacock Teal brand palette', () {
      expect(AppColors.primary, const Color(0xFF006874));
      expect(AppColors.primaryContainer, const Color(0xFF97F0FF));
      expect(AppColors.onPrimaryContainer, const Color(0xFF001F24));
      expect(AppColors.primaryTonal, const Color(0xFF4DB6C8));
      expect(AppColors.routeAccent, const Color(0xFFC2185B));
      expect(AppColors.success, const Color(0xFF2E7D32));
      expect(AppColors.warning, const Color(0xFFB26A00));
      expect(AppColors.error, const Color(0xFFBA1A1A));
      expect(AppColors.info, const Color(0xFF1976D2));
    });

    test('AppDimensions adheres to 4dp base grid', () {
      expect(AppDimensions.space4 % 4.0, 0.0);
      expect(AppDimensions.space8 % 4.0, 0.0);
      expect(AppDimensions.space12 % 4.0, 0.0);
      expect(AppDimensions.space16 % 4.0, 0.0);
      expect(AppDimensions.space24 % 4.0, 0.0);
      expect(AppDimensions.space32 % 4.0, 0.0);
      expect(AppDimensions.buttonHeight, 52.0);
      expect(AppDimensions.runActionButtonSize, 56.0);
      expect(AppDimensions.radiusCard, 16.0);
    });

    test('AppTheme generates valid light and dark ThemeData', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.brightness, Brightness.light);
      expect(light.colorScheme.primary, AppColors.primary);
      expect(dark.brightness, Brightness.dark);
      expect(dark.colorScheme.surface, AppColors.surfaceContainerDark);
    });

    test('AppTextStyles provides valid TextStyle instances with correct font sizes', () {
      expect(AppTextStyles.displayHero().fontSize, 56.0);
      expect(AppTextStyles.displayMetric().fontSize, 36.0);
      expect(AppTextStyles.displayCardStat().fontSize, 28.0);
      expect(AppTextStyles.headlineLarge().fontSize, 28.0);
      expect(AppTextStyles.titleLarge().fontSize, 20.0);
      expect(AppTextStyles.bodyMedium().fontSize, 14.0);
      expect(AppTextStyles.metricLabel().fontSize, 12.0);
    });
  });

  group('Design System Component Widgets', () {
    testWidgets('IndiRunButton and IndiRunControlButton render properly', (
      tester,
    ) async {
      bool pressed = false;
      bool controlPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                IndiRunButton(
                  label: 'Start Run',
                  onPressed: () => pressed = true,
                ),
                IndiRunControlButton(
                  variant: IndiRunControlVariant.pause,
                  onPressed: () => controlPressed = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Start Run'), findsOneWidget);
      await tester.tap(find.text('Start Run'));
      expect(pressed, isTrue);

      expect(find.byType(IndiRunControlButton), findsOneWidget);
      await tester.tap(find.byType(IndiRunControlButton));
      expect(controlPressed, isTrue);
    });

    testWidgets(
      'MetricDisplay and BigMetricTimer render duration and metrics',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Column(
                children: [
                  MetricDisplay(label: 'PACE', value: "5'12\"", unit: '/km'),
                  BigMetricTimer(duration: Duration(minutes: 24, seconds: 35)),
                ],
              ),
            ),
          ),
        );

        expect(find.text("5'12\""), findsOneWidget);
        expect(find.text('PACE'), findsOneWidget);
        expect(find.text('/km'), findsOneWidget);
        expect(find.text('00:24:35'), findsOneWidget);
      },
    );

    testWidgets('GpsStatusIndicator and RunStatusBadge render correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                GpsStatusIndicator(state: GpsAccuracyState.strong),
                RunStatusBadge(status: RunStatus.active),
              ],
            ),
          ),
        ),
      );

      expect(find.text('GPS Ready'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('DsPreviewScreen mounts and renders design system sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DsPreviewScreen())),
      );

      expect(find.byType(DsPreviewScreen), findsOneWidget);
      expect(find.text('IndiRun Design System'), findsOneWidget);
      expect(
        find.text('1. COLOR PALETTE (Peacock Teal System)'),
        findsOneWidget,
      );
      expect(find.text('2. TYPOGRAPHY HIERARCHY'), findsOneWidget);
    });
  });
}
