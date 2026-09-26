import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/app.dart';

void main() {
  testWidgets('Navigation from Home to Run and back', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IndiRunApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify on Home
    expect(find.text('Start Run'), findsOneWidget);

    // Tap Start Run
    await tester.tap(find.text('Start Run'));
    await tester.pumpAndSettle();

    // Verify reached Run screen
    expect(find.text('Active Run Tracking Screen'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify back on Home
    expect(find.text('Start Run'), findsOneWidget);
  });

  testWidgets('Navigation from Home to History and Run Detail', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IndiRunApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap History button
    await tester.tap(find.widgetWithText(OutlinedButton, 'History'));
    await tester.pumpAndSettle();

    // Verify on History screen
    expect(find.text('Sample Run Item'), findsOneWidget);

    // Tap run item to test parameterized detail route
    await tester.tap(find.text('Sample Run Item'));
    await tester.pumpAndSettle();

    // Verify on Run Detail screen
    expect(find.text('Run ID: test-run-123'), findsOneWidget);
  });

  testWidgets('Navigation from Home to Profile', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IndiRunApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Profile icon button in AppBar
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Verify on Profile screen
    expect(find.text('IndiRun Runner • Tier 2/3 India'), findsOneWidget);
  });
}
