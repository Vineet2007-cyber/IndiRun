import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/features/share/presentation/share_screen.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  testWidgets('ShareScreen renders template choices and controls',
      (tester) async {
    final extra = {
      'distanceKm': 5.02,
      'durationSeconds': 1780,
      'avgPaceSec': 355,
      'startedAt': DateTime(2026, 10, 4, 7, 30),
      'username': 'vineet',
      'elevGainM': 42.0,
      'routePoints': const [
        {'lat': 19.0760, 'lng': 72.8777},
        {'lat': 19.0780, 'lng': 72.8790},
      ],
    };

    await tester.pumpWidget(_wrap(ShareScreen(extra: extra)));
    await tester.pumpAndSettle();

    // Verify header title
    expect(find.text('Share your run'), findsOneWidget);

    // Verify all 4 template names appear in selector
    expect(find.text('Classic'), findsWidgets);
    expect(find.text('Route'), findsWidgets);
    expect(find.text('Stats'), findsWidgets);
    expect(find.text('Story'), findsWidgets);

    // Verify blur toggle and description
    expect(find.text('Hide start & end location'), findsOneWidget);
    expect(find.text('Protects your home/work address'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);

    // Verify CTA buttons
    expect(find.text('Share to...'), findsOneWidget);
    expect(find.text('Save to gallery'), findsOneWidget);
  });

  testWidgets('Tapping template updates selection', (tester) async {
    final extra = {
      'distanceKm': 4.2,
      'durationSeconds': 1400,
      'avgPaceSec': 333,
      'startedAt': DateTime.now(),
      'username': 'runner',
    };

    await tester.pumpWidget(_wrap(ShareScreen(extra: extra)));
    await tester.pumpAndSettle();

    // Tap 'Stats' template
    final statsFinder = find.text('Stats');
    expect(statsFinder, findsWidgets);
    await tester.tap(statsFinder.first);
    await tester.pumpAndSettle();

    // Tap 'Story' template
    final storyFinder = find.text('Story');
    expect(storyFinder, findsWidgets);
    await tester.tap(storyFinder.first);
    await tester.pumpAndSettle();
  });

  testWidgets('Toggling blur updates switch value', (tester) async {
    final extra = {
      'distanceKm': 2.5,
      'durationSeconds': 800,
      'avgPaceSec': 320,
      'startedAt': DateTime.now(),
      'username': 'runner',
    };

    await tester.pumpWidget(_wrap(ShareScreen(extra: extra)));
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    final initialSwitch = tester.widget<Switch>(switchFinder);
    expect(initialSwitch.value, isTrue);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    final updatedSwitch = tester.widget<Switch>(switchFinder);
    expect(updatedSwitch.value, isFalse);
  });
}
