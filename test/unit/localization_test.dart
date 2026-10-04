import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/core/localization/locale_provider.dart';

void main() {
  group('Localization — English-only (V1)', () {
    test('English locale loads all expected V1 keys', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.appTitle, 'IndiRun');
      expect(l10n.home, 'Home');
      expect(l10n.startRun, 'Start Run');
      expect(l10n.distance, 'Distance');
      expect(l10n.pace, 'Pace');
      expect(l10n.continueWithGoogle, 'Continue with Google');
      expect(l10n.editProfile, 'Edit profile');
      expect(l10n.displayName, 'Display Name');
      expect(l10n.units, 'Units');
      expect(l10n.kilometers, 'Kilometres');
      expect(l10n.miles, 'Miles');
      expect(l10n.deleteAccount, 'Delete Account');
      expect(l10n.signOut, 'Sign Out');
    });

    test('English is the only supported locale', () {
      final locales =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(locales, equals(['en']));
    });

    test('Hindi is NOT a supported locale', () {
      final locales =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(locales, isNot(contains('hi')));
    });

    test('Gujarati is NOT a supported locale', () {
      final locales =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(locales, isNot(contains('gu')));
    });

    test('AppLocalizations.delegate is not supported for Hindi locale', () {
      final supported = AppLocalizations.delegate.isSupported(const Locale('hi'));
      expect(supported, isFalse);
    });

    test('AppLocalizations.delegate is not supported for Gujarati locale', () {
      final supported = AppLocalizations.delegate.isSupported(const Locale('gu'));
      expect(supported, isFalse);
    });

    test('AppLocalizations.delegate is supported for English locale', () {
      final supported = AppLocalizations.delegate.isSupported(const Locale('en'));
      expect(supported, isTrue);
    });
  });

  group('LocaleNotifier — legacy preference safety', () {
    test('localeProvider always starts as English', () {
      // The notifier build() always returns Locale('en') regardless of any
      // previously stored preference.
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'en');
    });

    test('setLocale with legacy Hindi does not crash', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Must read first to initialize the notifier
      container.read(localeProvider);
      // Calling setLocale('hi') must not throw
      await expectLater(
        () => container.read(localeProvider.notifier).setLocale(const Locale('hi')),
        returnsNormally,
      );
      // State stays English regardless
      expect(container.read(localeProvider).languageCode, 'en');
    });

    test('setLocale with legacy Gujarati does not crash', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(localeProvider);
      await expectLater(
        () => container.read(localeProvider.notifier).setLocale(const Locale('gu')),
        returnsNormally,
      );
      expect(container.read(localeProvider).languageCode, 'en');
    });

    test('setLocale with null/missing preference uses English', () async {
      // Simulates startup when no preference is stored (new install)
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(localeProvider);
      await expectLater(
        () => container.read(localeProvider.notifier).setLocale(const Locale('en')),
        returnsNormally,
      );
      expect(container.read(localeProvider).languageCode, 'en');
    });
  });

  group('AppLanguage enum', () {
    test('only contains English in V1', () {
      expect(AppLanguage.values.length, 1);
      expect(AppLanguage.values.first, AppLanguage.english);
    });

    test('fromCode(null) returns English', () {
      expect(AppLanguage.fromCode(null), AppLanguage.english);
    });

    test('fromCode("en") returns English', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
    });

    test('fromCode("hi") returns English (legacy safety)', () {
      expect(AppLanguage.fromCode('hi'), AppLanguage.english);
    });

    test('fromCode("gu") returns English (legacy safety)', () {
      expect(AppLanguage.fromCode('gu'), AppLanguage.english);
    });

    test('fromLocale(Locale("hi")) returns English (legacy safety)', () {
      expect(AppLanguage.fromLocale(const Locale('hi')), AppLanguage.english);
    });

    test('fromLocale(Locale("gu")) returns English (legacy safety)', () {
      expect(AppLanguage.fromLocale(const Locale('gu')), AppLanguage.english);
    });
  });
}
