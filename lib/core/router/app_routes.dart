abstract final class AppRoutes {
  static const String root = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String username = '/username';
  static const String forgotPassword = '/forgot-password';
  static const String permission = '/permission';
  static const String home = '/home';
  static const String preRun = '/pre-run';
  static const String countdown = '/countdown';
  static const String activeRun = '/active-run';
  static const String runSummary = '/run-summary';
  static const String history = '/history';
  static const String share = '/share';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String dsPreview = '/ds-preview';

  // Keep legacy aliases so existing code compiles
  static const String auth = login;
  static const String onboarding = signup;
  static const String run = activeRun;
  static const String historyDetail = '/history/:runId';

  static String runDetailPath(String runId) => '/history/$runId';
}
