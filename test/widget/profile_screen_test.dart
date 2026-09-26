import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/core/localization/locale_provider.dart';
import 'package:indirun/core/theme/app_theme.dart';
import 'package:indirun/data/local/in_memory_auth_repository.dart';
import 'package:indirun/data/local/in_memory_profile_repository.dart';
import 'package:indirun/data/repositories/auth_repository.dart';
import 'package:indirun/data/repositories/repository_providers.dart';
import 'package:indirun/features/profile/domain/user_profile.dart';
import 'package:indirun/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders user details, settings, and allows name edit', (tester) async {
    const user = AuthUser(id: 'user-001', displayName: 'Pooja Shah', email: 'pooja@example.com');
    final authRepo = InMemoryAuthRepository(initialUser: user);
    final profileRepo = InMemoryProfileRepository({
      'user-001': UserProfile(
        id: 'user-001',
        displayName: 'Pooja Shah',
        email: 'pooja@example.com',
        createdAt: DateTime.now(),
      ),
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          profileRepositoryProvider.overrideWithValue(profileRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify user details
    expect(find.text('Pooja Shah'), findsOneWidget);
    expect(find.text('pooja@example.com'), findsOneWidget);

    // Verify settings sections
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Voice Cues'), findsOneWidget);
    expect(find.text('Auto-pause'), findsOneWidget);

    // Tap edit button to open dialog
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // Dialog should be open
    expect(find.text('Edit Profile'), findsOneWidget);
    final textFormField = find.byType(TextFormField);
    expect(textFormField, findsOneWidget);

    // Enter new name and save
    await tester.enterText(textFormField, 'Pooja S.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Profile should be updated
    expect(find.text('Pooja S.'), findsOneWidget);

    // Scroll to and verify sign out button
    await tester.scrollUntilVisible(find.text('Sign Out'), 200);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
