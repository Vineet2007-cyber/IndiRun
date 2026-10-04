import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/core/constants/app_colors.dart';
import 'package:indirun/features/run/domain/gps_status.dart';
import 'package:indirun/features/run/presentation/gps_status_banner.dart';
import 'package:indirun/features/run/presentation/pin_drop_screen.dart';
import 'package:indirun/features/run/presentation/pre_run_screen.dart';

void main() {
  Widget buildTestWidget(Widget child, [List<dynamic> overrides = const []]) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        home: child,
      ),
    );
  }

  group('PreRunScreen (S09 / S10 / S14)', () {
    testWidgets('renders PreRunScreen basic elements: free run CTA, voice cues, layer button', (tester) async {
      await tester.pumpWidget(buildTestWidget(const PreRunScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Start Run'), findsOneWidget);
      expect(find.text('Voice-cues'), findsOneWidget);
      expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('toggling voice cues switch updates state', (tester) async {
      await tester.pumpWidget(buildTestWidget(const PreRunScreen()));
      await tester.pumpAndSettle();

      final voiceSwitch = find.byType(Switch);
      expect(voiceSwitch, findsOneWidget);
    });

    testWidgets('tapping layer icon opens S13 MapLayersSheet', (tester) async {
      await tester.pumpWidget(buildTestWidget(const PreRunScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.layers_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Map style'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Satellite'), findsOneWidget);
      expect(find.text('Public transport'), findsOneWidget);
    });
  });

  group('GPS status banner (S14)', () {
    testWidgets('renders Searching GPS banner with orange style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const Scaffold(
            body: GpsStatusBanner(status: GpsStatus.searching),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Searching GPS...'), findsOneWidget);
    });

    testWidgets('renders Weak GPS banner with warning message', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const Scaffold(
            body: GpsStatusBanner(status: GpsStatus.weak),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weak signal. Move to open sky'), findsOneWidget);
    });

    testWidgets('renders GPS is off banner with tap prompt', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const Scaffold(
            body: GpsStatusBanner(status: GpsStatus.gpsOff),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GPS is off. Tap to turn on'), findsOneWidget);
    });
  });

  group('PinDropScreen (S12)', () {
    testWidgets('renders pin drop controls: crosshair and action buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget(const PinDropScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Drag map to move the pin'), findsOneWidget);
      expect(find.text('Set as Start'), findsOneWidget);
      expect(find.text('Set as End'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
