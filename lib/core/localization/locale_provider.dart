import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// IndiRun V1 supports English only.
///
/// The [AppLanguage] enum is kept as a single-entry type so the localization
/// architecture can support additional languages in the future without
/// structural changes. Hindi and Gujarati support was removed in V1.
enum AppLanguage {
  english(Locale('en'), 'English');

  final Locale locale;
  final String label;

  const AppLanguage(this.locale, this.label);

  /// Always returns [AppLanguage.english] in V1.
  /// Any legacy stored locale value ('hi', 'gu', or null) is silently
  /// treated as English — there is no crash on old stored preferences.
  static AppLanguage fromLocale(Locale locale) {
    return AppLanguage.english;
  }

  /// Always returns [AppLanguage.english] in V1.
  /// Legacy codes 'hi' and 'gu' are safely ignored.
  static AppLanguage fromCode(String? code) {
    return AppLanguage.english;
  }
}

/// Locale notifier locked to English for V1.
///
/// [setLocale] is a no-op that always keeps the state as [Locale('en')].
/// This means any old 'hi' or 'gu' preference read from SharedPreferences
/// or the database will be ignored — the app always displays in English.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return const Locale('en');
  }

  /// No-op in V1. The locale is always English regardless of input.
  Future<void> setLocale(Locale newLocale) async {
    state = const Locale('en');
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
