import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'IndiRun'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Every run, your own.'**
  String get tagline;

  /// No description provided for @welcomeToIndiRun.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeToIndiRun;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @startRun.
  ///
  /// In en, this message translates to:
  /// **'Start Run'**
  String get startRun;

  /// No description provided for @startYourFirstRun.
  ///
  /// In en, this message translates to:
  /// **'Start your first run'**
  String get startYourFirstRun;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @allHistory.
  ///
  /// In en, this message translates to:
  /// **'All history'**
  String get allHistory;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @run.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get run;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @avgPace.
  ///
  /// In en, this message translates to:
  /// **'Avg Pace'**
  String get avgPace;

  /// No description provided for @elevGain.
  ///
  /// In en, this message translates to:
  /// **'Elev Gain'**
  String get elevGain;

  /// No description provided for @bestKm.
  ///
  /// In en, this message translates to:
  /// **'Best Km'**
  String get bestKm;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @splits.
  ///
  /// In en, this message translates to:
  /// **'Splits'**
  String get splits;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @onboarding.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get onboarding;

  /// No description provided for @auth.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get auth;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get createPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New user?'**
  String get newUser;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered?'**
  String get alreadyRegistered;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @signUpWithGoogleToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google to get started'**
  String get signUpWithGoogleToGetStarted;

  /// No description provided for @googleVerificationNote.
  ///
  /// In en, this message translates to:
  /// **'Google is only used to verify you. Your Google name is never shown.'**
  String get googleVerificationNote;

  /// No description provided for @termsAndPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to Terms and Privacy Policy'**
  String get termsAndPrivacyNotice;

  /// No description provided for @pickYourRunnerName.
  ///
  /// In en, this message translates to:
  /// **'Pick your runner name'**
  String get pickYourRunnerName;

  /// No description provided for @howYouAppear.
  ///
  /// In en, this message translates to:
  /// **'This is how you appear in IndiRun.'**
  String get howYouAppear;

  /// No description provided for @stepTwoOfTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get stepTwoOfTwo;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @enterYourUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterYourUsername;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'We will email a reset link to the address linked with your Google account.'**
  String get resetPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox. Link expires in 30 minutes.'**
  String get checkYourInbox;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @allowLocationWhileRunning.
  ///
  /// In en, this message translates to:
  /// **'Allow location while running'**
  String get allowLocationWhileRunning;

  /// No description provided for @trackDistancePaceRoute.
  ///
  /// In en, this message translates to:
  /// **'Track distance, pace and route'**
  String get trackDistancePaceRoute;

  /// No description provided for @keepTrackingScreenLocked.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking with the screen locked'**
  String get keepTrackingScreenLocked;

  /// No description provided for @dataStaysPrivate.
  ///
  /// In en, this message translates to:
  /// **'Your data stays private until you share it'**
  String get dataStaysPrivate;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get allowLocation;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @changeLaterInSettings.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings'**
  String get changeLaterInSettings;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @pastRuns.
  ///
  /// In en, this message translates to:
  /// **'Past runs'**
  String get pastRuns;

  /// No description provided for @noRunsYet.
  ///
  /// In en, this message translates to:
  /// **'No runs yet'**
  String get noRunsYet;

  /// No description provided for @firstRunOneTap.
  ///
  /// In en, this message translates to:
  /// **'Your first run is one tap away.'**
  String get firstRunOneTap;

  /// No description provided for @startLocation.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLocation;

  /// No description provided for @endLocation.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLocation;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @searchByLocation.
  ///
  /// In en, this message translates to:
  /// **'Search by location'**
  String get searchByLocation;

  /// No description provided for @voiceCuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice-cues'**
  String get voiceCuesTitle;

  /// No description provided for @pickRouteToEnable.
  ///
  /// In en, this message translates to:
  /// **'Pick a route to enable'**
  String get pickRouteToEnable;

  /// No description provided for @leftRightPrompts.
  ///
  /// In en, this message translates to:
  /// **'Left / right prompts in earphones'**
  String get leftRightPrompts;

  /// No description provided for @twsConnected.
  ///
  /// In en, this message translates to:
  /// **'TWS connected'**
  String get twsConnected;

  /// No description provided for @testVoice.
  ///
  /// In en, this message translates to:
  /// **'Test voice'**
  String get testVoice;

  /// No description provided for @setupLockedOnceStarted.
  ///
  /// In en, this message translates to:
  /// **'Setup is locked once the run starts'**
  String get setupLockedOnceStarted;

  /// No description provided for @useMyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyCurrentLocation;

  /// No description provided for @cantFindChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Choose on map'**
  String get cantFindChooseOnMap;

  /// No description provided for @resultsLimitedToIndia.
  ///
  /// In en, this message translates to:
  /// **'Results limited to India'**
  String get resultsLimitedToIndia;

  /// No description provided for @dragMapToMovePin.
  ///
  /// In en, this message translates to:
  /// **'Drag map to move the pin'**
  String get dragMapToMovePin;

  /// No description provided for @setAsStart.
  ///
  /// In en, this message translates to:
  /// **'Set as Start'**
  String get setAsStart;

  /// No description provided for @setAsEnd.
  ///
  /// In en, this message translates to:
  /// **'Set as End'**
  String get setAsEnd;

  /// No description provided for @mapStyle.
  ///
  /// In en, this message translates to:
  /// **'Map style'**
  String get mapStyle;

  /// No description provided for @mapDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get mapDefault;

  /// No description provided for @mapSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get mapSatellite;

  /// No description provided for @mapPublicTransport.
  ///
  /// In en, this message translates to:
  /// **'Public transport'**
  String get mapPublicTransport;

  /// No description provided for @choiceRemembered.
  ///
  /// In en, this message translates to:
  /// **'Your choice is remembered for next time'**
  String get choiceRemembered;

  /// No description provided for @gpsSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching GPS...'**
  String get gpsSearching;

  /// No description provided for @gpsWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak signal. Move to open sky'**
  String get gpsWeak;

  /// No description provided for @gpsOff.
  ///
  /// In en, this message translates to:
  /// **'GPS is off. Tap to turn on'**
  String get gpsOff;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Open settings'**
  String get locationPermissionDenied;

  /// No description provided for @gpsReady.
  ///
  /// In en, this message translates to:
  /// **'GPS ready'**
  String get gpsReady;

  /// No description provided for @startDisabled.
  ///
  /// In en, this message translates to:
  /// **'Start disabled'**
  String get startDisabled;

  /// No description provided for @startBlocked.
  ///
  /// In en, this message translates to:
  /// **'Start blocked'**
  String get startBlocked;

  /// No description provided for @startAnyway.
  ///
  /// In en, this message translates to:
  /// **'Start anyway (asks to confirm)'**
  String get startAnyway;

  /// No description provided for @getReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get getReady;

  /// No description provided for @voiceGuidanceOn.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance is on'**
  String get voiceGuidanceOn;

  /// No description provided for @voiceGuidanceOff.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance is off'**
  String get voiceGuidanceOff;

  /// No description provided for @tapToCancel.
  ///
  /// In en, this message translates to:
  /// **'Tap to cancel'**
  String get tapToCancel;

  /// No description provided for @pauseRun.
  ///
  /// In en, this message translates to:
  /// **'Pause Run'**
  String get pauseRun;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @endRun.
  ///
  /// In en, this message translates to:
  /// **'End Run'**
  String get endRun;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @voiceOn.
  ///
  /// In en, this message translates to:
  /// **'Voice on'**
  String get voiceOn;

  /// No description provided for @voicePaused.
  ///
  /// In en, this message translates to:
  /// **'Voice paused'**
  String get voicePaused;

  /// No description provided for @endThisRun.
  ///
  /// In en, this message translates to:
  /// **'End this run?'**
  String get endThisRun;

  /// No description provided for @keepRunning.
  ///
  /// In en, this message translates to:
  /// **'Keep running'**
  String get keepRunning;

  /// No description provided for @veryShortRun.
  ///
  /// In en, this message translates to:
  /// **'Very short run'**
  String get veryShortRun;

  /// No description provided for @veryShortRunPrompt.
  ///
  /// In en, this message translates to:
  /// **'This run is under 100 m. Save or discard it?'**
  String get veryShortRunPrompt;

  /// No description provided for @runComplete.
  ///
  /// In en, this message translates to:
  /// **'Run complete'**
  String get runComplete;

  /// No description provided for @voiceGuided.
  ///
  /// In en, this message translates to:
  /// **'Voice-guided'**
  String get voiceGuided;

  /// No description provided for @saveRun.
  ///
  /// In en, this message translates to:
  /// **'Save run'**
  String get saveRun;

  /// No description provided for @shareYourRun.
  ///
  /// In en, this message translates to:
  /// **'Share your run'**
  String get shareYourRun;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @routeFocus.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeFocus;

  /// No description provided for @statsFocus.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsFocus;

  /// No description provided for @story.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get story;

  /// No description provided for @blurStartAndEnd.
  ///
  /// In en, this message translates to:
  /// **'Blur start and end of route'**
  String get blurStartAndEnd;

  /// No description provided for @shareTo.
  ///
  /// In en, this message translates to:
  /// **'Share to...'**
  String get shareTo;

  /// No description provided for @saveImageToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save image to gallery'**
  String get saveImageToGallery;

  /// No description provided for @runsCount.
  ///
  /// In en, this message translates to:
  /// **'RUNS'**
  String get runsCount;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @turnOnByDefault.
  ///
  /// In en, this message translates to:
  /// **'Turn on by default'**
  String get turnOnByDefault;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @kilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometres'**
  String get kilometers;

  /// No description provided for @miles.
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get miles;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'PERMISSIONS'**
  String get permissions;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @termsAndPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Terms and Privacy Policy'**
  String get termsAndPrivacyPolicy;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @changingNameUpdatesCards.
  ///
  /// In en, this message translates to:
  /// **'Changing your name updates your past share cards'**
  String get changingNameUpdatesCards;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Runs will sync later.'**
  String get youAreOffline;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Will retry automatically.'**
  String get syncFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @unfinishedRunFound.
  ///
  /// In en, this message translates to:
  /// **'Unfinished run found'**
  String get unfinishedRunFound;

  /// No description provided for @mapFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Map failed to load'**
  String get mapFailedToLoad;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This will delete your profile and account.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterDisplayName;

  /// No description provided for @displayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Display name cannot be empty'**
  String get displayNameRequired;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
