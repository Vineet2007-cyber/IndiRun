enum AppEnvironment {
  dev,
  staging,
  prod,
}

class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String oauthRedirectUrl;
  final bool enableLogging;

  const AppConfig({
    required this.environment,
    required this.appName,
    this.supabaseUrl = '',
    this.supabaseAnonKey = '',
    this.oauthRedirectUrl = 'indirun://login-callback',
    this.enableLogging = true,
  });

  bool get isProduction => environment == AppEnvironment.prod;
  bool get isDevelopment => environment == AppEnvironment.dev;
  bool get isSupabaseConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  String get publishableKey => supabaseAnonKey;

  factory AppConfig.fromEnvironment() {
    const envString = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    final environment = switch (envString.toLowerCase()) {
      'prod' || 'production' => AppEnvironment.prod,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.dev,
    };

    const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const rawKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: '');
    final supabaseAnonKey = rawKey.isNotEmpty
        ? rawKey
        : const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    const oauthRedirectUrl = String.fromEnvironment(
      'SUPABASE_REDIRECT_URL',
      defaultValue: 'indirun://login-callback',
    );

    return AppConfig(
      environment: environment,
      appName: 'IndiRun',
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      oauthRedirectUrl: oauthRedirectUrl,
      enableLogging: environment != AppEnvironment.prod,
    );
  }
}
