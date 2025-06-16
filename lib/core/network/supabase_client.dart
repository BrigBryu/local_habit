import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class SupabaseClientService {
  static SupabaseClientService? _instance;
  static SupabaseClientService get instance {
    _instance ??= SupabaseClientService._();
    return _instance!;
  }

  SupabaseClientService._();

  final _logger = Logger();
  bool _initialized = false;

  SupabaseClient get supabase {
    if (!_initialized) {
      throw Exception(
          'SupabaseClientService not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }

  Future<void> initialize() async {
    if (_initialized) {
      _logger.d('Supabase already initialized');
      return;
    }

    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception('Missing Supabase credentials in .env file');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        debug: true, // Enable verbose debugging
      );

      _initialized = true;
      _logger.i('Supabase initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Supabase',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  bool get isInitialized => _initialized;

  bool get isOnline {
    try {
      // Simple check - in a real app you'd want more sophisticated network detection
      return _initialized && supabase.auth.currentSession != null;
    } catch (e) {
      return false;
    }
  }
}

// Convenience getter for global access
SupabaseClient get supabase => SupabaseClientService.instance.supabase;
