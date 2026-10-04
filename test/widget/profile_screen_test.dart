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
  group('ProfileScreen', () {
    Widget buildProfileScreen({
      AuthUser? user,
      UserProfile? profile,
    }) {
      final testUser = user ??
          const AuthUser(
            id: 'user-001',
            displayName: 'Pooja Shah',
            email: 'pooja@example.com',
          );
      final authRepo = InMemoryAuthRepository(initialUser: testUser);
      final profileRepo = InMemoryProfileRepository({
        testUser.id: profile ??
            UserProfile(
              id: testUser.id,
              displayName: testUser.displayName ?? 'Runner',
              email: testUser.email,
              createdAt: DateTime.now(),
            ),
      });

      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          profileRepositoryProvider.overrideWithValue(profileRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
        ),
      );
    }

    testWidgets('renders username and avatar initial', (tester) async {
      await tester.pumpWidget(buildProfileScreen());
      await tester.pumpAndSettle();

      // Avatar initial 'P' for 'Pooja Shah'
      expect(find.text('P'), findsOneWidget);
      // @username text
      expect(find.text('@Pooja Shah'), findsOneWidget);
    });

    testWidgets('does NOT contain a Language selector', (tester) async {
      // V1 is English-only — no language UI should be present in the profile.
      await tester.pumpWidget(buildProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsNothing);
      expect(find.text('Hindi'), findsNothing);
      expect(find.text('Gujarati'), findsNothing);
      expect(find.text('English'), findsNothing); // no language picker at all
    });

    testWidgets('contains Edit profile button', (tester) async {
      await tester.pumpWidget(buildProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Edit profile'), findsOneWidget);
    });

    testWidgets('contains Logout button', (tester) async {
      await tester.pumpWidget(buildProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('app starts correctly with no saved language preference', (tester) async {
      // When there is no stored language preference the app defaults to English
      await tester.pumpWidget(buildProfileScreen());
      await tester.pumpAndSettle();

      // Profile screen renders without crash
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('AppLanguage locale safety', () {
    test('AppLanguage.fromCode returns English for null (no saved preference)', () {
      expect(AppLanguage.fromCode(null), AppLanguage.english);
    });

    test('AppLanguage.fromCode returns English for legacy hi preference', () {
      expect(AppLanguage.fromCode('hi'), AppLanguage.english);
    });

    test('AppLanguage.fromCode returns English for legacy gu preference', () {
      expect(AppLanguage.fromCode('gu'), AppLanguage.english);
    });

    test('AppLanguage.fromCode returns English for en preference', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
    });

    test('AppLanguage.fromLocale always returns English', () {
      expect(AppLanguage.fromLocale(const Locale('en')), AppLanguage.english);
      expect(AppLanguage.fromLocale(const Locale('hi')), AppLanguage.english);
      expect(AppLanguage.fromLocale(const Locale('gu')), AppLanguage.english);
    });

    test('Hindi is not in AppLocalizations.supportedLocales', () {
      final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(codes, isNot(contains('hi')));
    });

    test('Gujarati is not in AppLocalizations.supportedLocales', () {
      final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(codes, isNot(contains('gu')));
    });

    test('English is the only supported locale', () {
      final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(codes, equals(['en']));
    });
  });
}
