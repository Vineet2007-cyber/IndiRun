import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.english;
    for (final lang in AppLanguage.values) {
      if (lang.locale.languageCode == code) {
        return lang;
      }
    }
    return AppLanguage.english;
  }
}

class LocaleNotifier extends Notifier<Locale> {
  static const String prefKey = 'indirun_language_code';

  @override
  Locale build() {
    _loadPersistedLocale();
    return AppLanguage.english.locale;
  }

  Future<void> _loadPersistedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(prefKey);
      if (code != null && code.isNotEmpty) {
        final language = AppLanguage.fromCode(code);
        if (state != language.locale) {
          state = language.locale;
        }
      }
    } catch (_) {
      // Graceful fallback to default in case shared preferences fails
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    state = newLocale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefKey, newLocale.languageCode);
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    await setLocale(language.locale);
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
