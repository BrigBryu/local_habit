import 'package:logger/logger.dart';

/// Application flavors for different environments
enum AppFlavor {
  dev,
  prod;

  static AppFlavor get current {
    const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'prod');

    switch (flavorName.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppFlavor.dev;
      case 'prod':
      case 'production':
      default:
        return AppFlavor.prod;
    }
  }

  bool get isDev => this == AppFlavor.dev;
  bool get isProd => this == AppFlavor.prod;

  String get name {
    switch (this) {
      case AppFlavor.dev:
        return 'Development';
      case AppFlavor.prod:
        return 'Production';
    }
  }

  String get envFile {
    switch (this) {
      case AppFlavor.dev:
        return '.env.dev';
      case AppFlavor.prod:
        return '.env';
    }
  }
}

/// Configuration service based on app flavor
class FlavorConfig {
  static FlavorConfig? _instance;
  static FlavorConfig get instance => _instance ??= FlavorConfig._();

  FlavorConfig._();

  final Logger _logger = Logger();
  late final AppFlavor _flavor;

  void initialize(AppFlavor flavor) {
    _flavor = flavor;
    _logger.i('App initialized with flavor: ${flavor.name}');

    // Configure logging based on flavor
    if (flavor.isProd) {
      // In production, reduce log verbosity
      Logger.level = Level.warning;
    } else {
      // In development, show all logs
      Logger.level = Level.debug;
    }
  }

  AppFlavor get flavor => _flavor;

  bool get isDev => _flavor.isDev;
  bool get isProd => _flavor.isProd;

  /// Whether to show debug information in UI
  bool get showDebugInfo => isDev;

  /// Whether to enable performance monitoring
  bool get enablePerformanceMonitoring => isProd;

  /// Whether to enable crash reporting
  bool get enableCrashReporting => isProd;

  /// API timeout duration
  Duration get apiTimeout =>
      isDev ? const Duration(seconds: 30) : const Duration(seconds: 15);

  /// Database sync interval
  Duration get syncInterval =>
      isDev ? const Duration(minutes: 1) : const Duration(minutes: 5);

  /// Maximum number of retry attempts
  int get maxRetryAttempts => isDev ? 3 : 5;

  /// Whether to use local test data
  bool get useTestData => isDev;

  /// Supabase configuration
  String get supabaseUrl {
    switch (_flavor) {
      case AppFlavor.dev:
        return 'http://127.0.0.1:54321'; // Local Supabase
      case AppFlavor.prod:
        return 'https://ffemtzuqmgqkitbyfvrn.supabase.co'; // Production Supabase
    }
  }

  /// Log configuration info
  void logConfig() {
    _logger.i('''
🔧 App Configuration:
   Flavor: ${_flavor.name}
   Debug Info: $showDebugInfo
   Performance Monitoring: $enablePerformanceMonitoring
   Crash Reporting: $enableCrashReporting
   API Timeout: ${apiTimeout.inSeconds}s
   Sync Interval: ${syncInterval.inMinutes}m
   Max Retries: $maxRetryAttempts
   Supabase URL: $supabaseUrl
''');
  }
}
