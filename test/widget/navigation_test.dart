import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/app.dart';
import 'package:indirun/data/local/in_memory_auth_repository.dart';
import 'package:indirun/data/repositories/auth_repository.dart';
import 'package:indirun/data/repositories/repository_providers.dart';

void main() {
  final authRepo = InMemoryAuthRepository(
    initialUser: const AuthUser(
      id: 'runner-007',
      displayName: 'Karan Dave',
      email: 'karan@example.com',
    ),
  );

  testWidgets('Navigation from Home to Run and back', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
        child: const IndiRunApp(),
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
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
        child: const IndiRunApp(),
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
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
        child: const IndiRunApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Profile icon button in AppBar
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Verify on Profile screen
    expect(find.text('Karan Dave'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sign Out'), 200);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
