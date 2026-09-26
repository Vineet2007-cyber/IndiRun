import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/core/localization/locale_provider.dart';

void main() {
  group('Localization', () {
    test('verifies English localizations', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.appTitle, 'IndiRun');
      expect(l10n.home, 'Home');
      expect(l10n.startRun, 'Start Run');
      expect(l10n.distance, 'Distance');
      expect(l10n.pace, 'Pace');
    });

    test('verifies Hindi localizations', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('hi'));
      expect(l10n.appTitle, 'इंडीरन');
      expect(l10n.home, 'होम');
      expect(l10n.startRun, 'दौड़ शुरू करें');
      expect(l10n.distance, 'दूरी');
      expect(l10n.pace, 'गति');
    });

    test('verifies Gujarati localizations', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('gu'));
      expect(l10n.appTitle, 'ઇન્ડીરન');
      expect(l10n.home, 'હોમ');
      expect(l10n.startRun, 'દોડ શરૂ કરો');
      expect(l10n.distance, 'અંતર');
      expect(l10n.pace, 'ઝડપ');
    });

    test('verifies all supported locales are registered', () {
      final locales = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(locales, containsAll(['en', 'hi', 'gu']));
    });
  });
}
