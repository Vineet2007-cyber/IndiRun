import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:indirun/core/router/app_routes.dart';
import 'package:indirun/features/run/presentation/run_summary_screen.dart';

Widget _wrap(Widget child) {
  final router = GoRouter(
    initialLocation: AppRoutes.runSummary,
    routes: [
      GoRoute(
        path: AppRoutes.runSummary,
        builder: (context, state) => child,
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: Text('Home Screen')),
      ),
      GoRoute(
        path: AppRoutes.share,
        builder: (context, state) => const Scaffold(body: Text('Share Screen')),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('RunSummaryScreen renders summary metrics and time-based title',
      (tester) async {
    final startedAt = DateTime(2026, 10, 4, 7, 30); // 7:30 AM -> Morning Run
    final extra = {
      'distanceKm': 5.02,
      'durationSeconds': 1780, // 29:40
      'avgPaceSec': 355, // 5:55
      'startedAt': startedAt,
      'voiceOn': true,
      'elevGainM': 42.0,
      'routePoints': const [
        {'lat': 19.0760, 'lng': 72.8777},
        {'lat': 19.0780, 'lng': 72.8790},
      ],
    };

    await tester.pumpWidget(_wrap(RunSummaryScreen(extra: extra)));
    await tester.pumpAndSettle();

    // Verify default title is 'Morning Run'
    expect(find.text('Morning Run'), findsOneWidget);

    // Verify distance
    expect(find.text('5.02 km'), findsOneWidget);

    // Verify duration and pace
    expect(find.text('29:40'), findsOneWidget);
    expect(find.text('5:55 /km'), findsOneWidget);

    // Verify voice guided indicator
    expect(find.text('Voice-guided'), findsOneWidget);

    // Verify Save, Share and Discard buttons
    expect(find.text('Save run'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);
  });

  testWidgets('RunSummaryScreen allows editing run title', (tester) async {
    final extra = {
      'distanceKm': 3.10,
      'durationSeconds': 1200,
      'avgPaceSec': 387,
      'startedAt': DateTime(2026, 10, 4, 18, 0), // 6:00 PM -> Evening Run
    };

    await tester.pumpWidget(_wrap(RunSummaryScreen(extra: extra)));
    await tester.pumpAndSettle();

    expect(find.text('Evening Run'), findsOneWidget);

    final titleFinder = find.byType(TextField);
    expect(titleFinder, findsOneWidget);

    await tester.enterText(titleFinder, 'My Sunset 5K');
    await tester.pumpAndSettle();

    expect(find.text('My Sunset 5K'), findsOneWidget);
  });

  testWidgets('Discard button navigates to Home', (tester) async {
    final extra = {
      'distanceKm': 1.0,
      'durationSeconds': 300,
      'avgPaceSec': 300,
      'startedAt': DateTime.now(),
    };

    await tester.pumpWidget(_wrap(RunSummaryScreen(extra: extra)));
    await tester.pumpAndSettle();

    final discardFinder = find.text('Discard');
    await tester.ensureVisible(discardFinder);
    await tester.tap(discardFinder);
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
  });
}
