import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/core/localization/locale_provider.dart';
import 'package:indirun/core/theme/app_theme.dart';
import 'package:indirun/data/local/in_memory_auth_repository.dart';
import 'package:indirun/data/repositories/repository_providers.dart';
import 'package:indirun/features/auth/presentation/auth_screen.dart';

void main() {
  testWidgets('AuthScreen renders Google OAuth button and branding', (tester) async {
    final fakeRepo = InMemoryAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AuthScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify brand title
    expect(find.text('IndiRun'), findsOneWidget);

    // Verify Google sign-in button
    expect(find.text('Continue with Google'), findsOneWidget);

    // Tap Google sign-in button
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    // Verify authenticated user was populated in repo
    expect(fakeRepo.isAuthenticated, isTrue);
  });
}
