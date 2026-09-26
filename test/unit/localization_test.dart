import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/core/localization/locale_provider.dart';

void main() {
  group('Localization', () {
    test('verifies English localizations including M1 keys', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.appTitle, 'IndiRun');
      expect(l10n.home, 'Home');
      expect(l10n.startRun, 'Start Run');
      expect(l10n.distance, 'Distance');
      expect(l10n.pace, 'Pace');
      expect(l10n.continueWithGoogle, 'Continue with Google');
      expect(l10n.editProfile, 'Edit Profile');
      expect(l10n.displayName, 'Display Name');
      expect(l10n.units, 'Units');
      expect(l10n.kilometers, 'Kilometers');
      expect(l10n.miles, 'Miles');
      expect(l10n.deleteAccount, 'Delete Account');
      expect(l10n.signOut, 'Sign Out');
    });

    test('verifies Hindi localizations including M1 keys', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('hi'));
      expect(l10n.appTitle, 'इंडीरन');
      expect(l10n.home, 'होम');
      expect(l10n.startRun, 'दौड़ शुरू करें');
      expect(l10n.distance, 'दूरी');
      expect(l10n.pace, 'गति');
      expect(l10n.continueWithGoogle, 'Google के साथ जारी रखें');
      expect(l10n.editProfile, 'प्रोफ़ाइल संपादित करें');
      expect(l10n.displayName, 'नाम');
      expect(l10n.units, 'इकाइयाँ');
      expect(l10n.deleteAccount, 'खाता हटाएं');
    });

    test('verifies Gujarati localizations including M1 keys', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('gu'));
      expect(l10n.appTitle, 'ઇન્ડીરન');
      expect(l10n.home, 'હોમ');
      expect(l10n.startRun, 'દોડ શરૂ કરો');
      expect(l10n.distance, 'અંતર');
      expect(l10n.pace, 'ઝડપ');
      expect(l10n.continueWithGoogle, 'Google સાથે આગળ વધો');
      expect(l10n.editProfile, 'પ્રોફાઇલ સંપાદિત કરો');
      expect(l10n.displayName, 'નામ');
      expect(l10n.units, 'એકમો');
      expect(l10n.deleteAccount, 'ખાતું કાઢી નાખો');
    });

    test('verifies all supported locales are registered', () {
      final locales = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(locales, containsAll(['en', 'hi', 'gu']));
    });
  });
}
