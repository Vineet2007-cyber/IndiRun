abstract final class AppRoutes {
  static const String root = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String run = '/run';
  static const String history = '/history';
  static const String historyDetail = '/history/:runId';
  static const String share = '/share';
  static const String profile = '/profile';

  static String runDetailPath(String runId) => '/history/$runId';
}
