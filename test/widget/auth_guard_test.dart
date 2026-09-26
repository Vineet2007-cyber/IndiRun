import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/app.dart';
import 'package:indirun/data/local/in_memory_auth_repository.dart';
import 'package:indirun/data/repositories/auth_repository.dart';
import 'package:indirun/data/repositories/repository_providers.dart';

void main() {
  testWidgets('Unauthenticated user is redirected to Auth screen', (tester) async {
    final unauthRepo = InMemoryAuthRepository(); // currentUser is null

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(unauthRepo),
        ],
        child: const IndiRunApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify redirected to Auth screen instead of Home
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Start Run'), findsNothing);
  });

  testWidgets('Authenticated user is redirected to Home screen', (tester) async {
    final authRepo = InMemoryAuthRepository(
      initialUser: const AuthUser(
        id: 'test-user',
        displayName: 'Aarav Patel',
        email: 'aarav@example.com',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
        child: const IndiRunApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify reached Home screen with greeting
    expect(find.text('Start Run'), findsOneWidget);
    expect(find.textContaining('Aarav Patel'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
  });
}
