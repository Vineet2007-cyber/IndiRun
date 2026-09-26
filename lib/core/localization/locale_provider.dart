import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

enum AppLanguage {
  english(Locale('en'), 'English', 'English'),
  hindi(Locale('hi'), 'Hindi', 'हिन्दी'),
  gujarati(Locale('gu'), 'Gujarati', 'ગુજરાતી');

  final Locale locale;
  final String label;
  final String nativeLabel;

  const AppLanguage(this.locale, this.label, this.nativeLabel);

  static AppLanguage fromLocale(Locale locale) {
    for (final lang in AppLanguage.values) {
      if (lang.locale.languageCode == locale.languageCode) {
        return lang;
      }
    }
    return AppLanguage.english;
  }
}

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return AppLanguage.english.locale;
  }

  void setLocale(Locale newLocale) {
    state = newLocale;
  }

  void setLanguage(AppLanguage language) {
    state = language.locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    assert(
      localizations != null,
      'No AppLocalizations found in context. Make sure localization delegates are configured.',
    );
    return localizations!;
  }
}
