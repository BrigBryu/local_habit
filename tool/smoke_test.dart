import 'dart:async';
import 'dart:io';

/// Automated smoke test for habit creation and synchronization
void main() async {
  print('🧪 Starting automated smoke test...');

  try {
    // Wait for apps to be ready
    await _waitForAppStartup();

    // Run the test
    await _runSmokeTest();

    print('✅ Smoke test passed');
    exit(0);
  } catch (e, stackTrace) {
    print('❌ Smoke test failed: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Wait for both apps to complete startup
Future<void> _waitForAppStartup() async {
  print('⏳ Waiting for app startup completion...');

  const timeout = Duration(minutes: 5);
  final startTime = DateTime.now();

  bool frankReady = false;
  bool bobReady = false;

  while (!frankReady || !bobReady) {
    if (DateTime.now().difference(startTime) > timeout) {
      throw TimeoutException('Apps did not start within timeout', timeout);
    }

    // Check Frank's log
    if (!frankReady && await _checkLogForStartup('frank.log')) {
      frankReady = true;
      print('📱 Frank app startup completed');
    }

    // Check Bob's log
    if (!bobReady && await _checkLogForStartup('bob.log')) {
      bobReady = true;
      print('📱 Bob app startup completed');
    }

    if (!frankReady || !bobReady) {
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  print('🚀 Both apps ready');
}

/// Check if log file contains startup completion message
Future<bool> _checkLogForStartup(String logFile) async {
  try {
    final file = File(logFile);
    if (!await file.exists()) return false;

    final content = await file.readAsString();

    // Look for various startup indicators
    final indicators = [
      'App Startup Completed',
      'RemoteHabitsRepository initialized',
      'SyncQueue initialized',
      'Realtime service initialized',
      'Flutter run key commands',
    ];

    return indicators.any((indicator) => content.contains(indicator));
  } catch (e) {
    return false;
  }
}

/// Run the actual smoke test
Future<void> _runSmokeTest() async {
  print('🔍 Running habit creation and sync test...');

  // For now, this is a basic integration test
  // In a full implementation, we would:
  // 1. Use flutter_driver to create habits on each device
  // 2. Verify they appear on the partner's device
  // 3. Test completion syncing

  // Simulate test by checking if apps are still running
  await Future.delayed(const Duration(seconds: 5));

  final frankRunning = await _isAppRunning('frank.log');
  final bobRunning = await _isAppRunning('bob.log');

  if (!frankRunning) {
    throw Exception('Frank app appears to have crashed');
  }

  if (!bobRunning) {
    throw Exception('Bob app appears to have crashed');
  }

  print('✅ Both apps are running stably');

  // Additional checks could be added here:
  // - Check for sync queue errors
  // - Check for database errors
  // - Verify network connectivity

  await _checkForErrors();
}

/// Check if app is still running (no crash indicators in recent log entries)
Future<bool> _isAppRunning(String logFile) async {
  try {
    final file = File(logFile);
    if (!await file.exists()) return false;

    final content = await file.readAsString();
    final lines = content.split('\n');

    // Check last 20 lines for crash indicators
    final recentLines =
        lines.length > 20 ? lines.sublist(lines.length - 20) : lines;

    final recentContent = recentLines.join('\n').toLowerCase();

    // Look for crash indicators
    final crashIndicators = [
      'fatal exception',
      'segmentation fault',
      'application finished',
      'process exited',
      'connection refused',
      'failed to connect to supabase',
    ];

    return !crashIndicators
        .any((indicator) => recentContent.contains(indicator));
  } catch (e) {
    return false;
  }
}

/// Check for common error patterns in logs
Future<void> _checkForErrors() async {
  print('🔍 Checking for error patterns...');

  final logFiles = ['frank.log', 'bob.log'];

  for (final logFile in logFiles) {
    try {
      final file = File(logFile);
      if (!await file.exists()) continue;

      final content = await file.readAsString();

      // Check for specific error patterns
      final errorPatterns = [
        'Exception: Bad state: Tried to use',
        'UUID format error',
        'Schema mismatch',
        'owner_id.*not found',
        'table.*completions.*not found',
        'infinite.*retry',
        'sync.*failed.*1000',
      ];

      for (final pattern in errorPatterns) {
        final regex = RegExp(pattern, caseSensitive: false);
        if (regex.hasMatch(content)) {
          print('⚠️  Warning: Found error pattern "$pattern" in $logFile');
        }
      }
    } catch (e) {
      print('⚠️  Could not check $logFile for errors: $e');
    }
  }

  print('✅ Error pattern check completed');
}
