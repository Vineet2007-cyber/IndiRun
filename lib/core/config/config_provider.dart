import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_config.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(
    environment: AppEnvironment.dev,
    appName: 'IndiRun',
    enableLogging: true,
  );
});
