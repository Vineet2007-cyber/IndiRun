import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/app.dart';
import 'package:indirun/data/local/in_memory_auth_repository.dart';
import 'package:indirun/data/repositories/auth_repository.dart';
import 'package:indirun/data/repositories/repository_providers.dart';

void main() {
  testWidgets('IndiRunApp renders and shows branding and home action when authenticated', (tester) async {
    final authRepo = InMemoryAuthRepository(
      initialUser: const AuthUser(
        id: 'test-runner',
        displayName: 'Test Runner',
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

    // Verify app title branding is present
    expect(find.text('IndiRun'), findsOneWidget);

    // Verify primary run action is present on home screen
    expect(find.text('Start Run'), findsOneWidget);
  });
}
