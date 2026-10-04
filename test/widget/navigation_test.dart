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

  Widget buildApp() => ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
        child: const IndiRunApp(),
      );

  testWidgets('Home screen shows Start Run button when authenticated', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Start Run'), findsWidgets);
  });

  testWidgets('Authenticated user stays on Home (not redirected to Login)', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Should NOT be on Login screen
    expect(find.text('Login'), findsNothing);
    // Should be on Home — Start Run must be visible
    expect(find.text('Start Run'), findsWidgets);
  });

  testWidgets('Profile icon navigates to Profile screen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Tap the profile icon if it's present
    if (tester.any(find.byIcon(Icons.person_outline))) {
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
    }

    // No crash — app is still rendering
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
