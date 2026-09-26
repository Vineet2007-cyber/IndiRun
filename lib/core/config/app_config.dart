enum AppEnvironment {
  dev,
  staging,
  prod,
}

class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final bool enableLogging;

  const AppConfig({
    required this.environment,
    required this.appName,
    this.enableLogging = true,
  });

  bool get isProduction => environment == AppEnvironment.prod;
  bool get isDevelopment => environment == AppEnvironment.dev;
}
