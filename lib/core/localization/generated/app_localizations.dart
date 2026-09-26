import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'IndiRun'**
  String get appTitle;

  /// Welcome message shown on onboarding
  ///
  /// In en, this message translates to:
  /// **'Welcome to IndiRun'**
  String get welcomeToIndiRun;

  /// Home screen title and navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Button label to initiate a run
  ///
  /// In en, this message translates to:
  /// **'Start Run'**
  String get startRun;

  /// History screen title and navigation label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Profile screen title and navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Generic run label or active run screen title
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get run;

  /// Label for running distance
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Label for running duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Label for running pace
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// Label for average pace
  ///
  /// In en, this message translates to:
  /// **'Avg Pace'**
  String get avgPace;

  /// Button or action label to share run
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Save action label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel action label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get onboarding;

  /// Sign in / Authentication title
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get auth;

  /// Sign in button with Google
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Sign in action
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign out action
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Edit profile action
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// User display name field label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// User email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Language selection setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Measurement units setting label
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// Metric distance unit
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get kilometers;

  /// Imperial distance unit
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get miles;

  /// Delete account action
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Confirmation title for account deletion
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountConfirmTitle;

  /// Confirmation message for account deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This will delete your profile and account.'**
  String get deleteAccountConfirmBody;

  /// Error message when authentication fails
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Retry action label
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Saving state message
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Saved successfully message
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Voice cues setting label
  ///
  /// In en, this message translates to:
  /// **'Voice Cues'**
  String get voiceCues;

  /// Auto pause setting label
  ///
  /// In en, this message translates to:
  /// **'Auto-pause'**
  String get autoPause;

  /// Battery guidance setting label
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization Guidance'**
  String get batteryGuidance;

  /// Privacy policy setting label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service setting label
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Notice for features scheduled in later milestones
  ///
  /// In en, this message translates to:
  /// **'Coming in upcoming release'**
  String get comingSoon;

  /// Hint for display name input
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterDisplayName;

  /// Validation error for empty display name
  ///
  /// In en, this message translates to:
  /// **'Display name cannot be empty'**
  String get displayNameRequired;

  /// Get started call to action button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
