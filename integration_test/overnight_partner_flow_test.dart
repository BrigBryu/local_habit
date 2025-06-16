import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:habit_level_up/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Overnight Partner Flow Test', () {
    late String deviceId;
    late String userEmail;
    late String logFilePath;
    late String csvFilePath;

    setUpAll(() async {
      // Get device ID and test user override
      final deviceIdResult = await Process.run('adb', ['get-serialno']);
      deviceId = deviceIdResult.stdout.toString().trim();

      userEmail =
          Platform.environment['TEST_USER_OVERRIDE'] ?? 'test@example.com';

      // Setup log files
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      logFilePath = 'logs/overnight_${deviceId}_$timestamp.log';
      csvFilePath = 'logs/overnight_results_${deviceId}_$timestamp.csv';

      // Create logs directory
      await Directory('logs').create(recursive: true);
      await Directory('screenshots').create(recursive: true);

      // Initialize CSV file
      final csvFile = File(csvFilePath);
      await csvFile.writeAsString('timestamp,scenario,action,result,details\n');

      // Log test start
      await _logMessage(logFilePath,
          'STARTING OVERNIGHT TEST - Device: $deviceId, User: $userEmail');
    });

    testWidgets('8 Hour Partner Flow Loop', (WidgetTester tester) async {
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(hours: 8));
      int scenarioCount = 0;

      while (DateTime.now().isBefore(endTime)) {
        scenarioCount++;
        await _logMessage(logFilePath, 'SCENARIO $scenarioCount START');
        await _logCsv(
            csvFilePath, 'SCENARIO $scenarioCount', 'START', 'SUCCESS', '');

        try {
          // Clear app state
          await _clearAppState(tester);

          // Initialize app
          app.main();
          await tester.pumpAndSettle(Duration(seconds: 5));

          // Take screenshot
          await _takeScreenshot('scenario_${scenarioCount}_start');

          // Perform partner flow based on device
          if (deviceId.contains('5554')) {
            await _performDeviceAFlow(tester, scenarioCount);
          } else if (deviceId.contains('5556')) {
            await _performDeviceBFlow(tester, scenarioCount);
          }

          await _logCsv(csvFilePath, 'SCENARIO $scenarioCount', 'COMPLETE',
              'SUCCESS', '');
        } catch (e, stackTrace) {
          await _logMessage(logFilePath, 'SCENARIO $scenarioCount ERROR: $e');
          await _logMessage(logFilePath, 'STACK TRACE: $stackTrace');
          await _logCsv(csvFilePath, 'SCENARIO $scenarioCount', 'ERROR',
              'FAILURE', e.toString());

          // Take error screenshot
          await _takeScreenshot('scenario_${scenarioCount}_error');
        }

        // Wait 10 minutes before next scenario
        await Future.delayed(Duration(minutes: 10));
      }

      await _logMessage(logFilePath,
          'OVERNIGHT TEST COMPLETED - Total scenarios: $scenarioCount');
      await _logCsv(csvFilePath, 'TEST', 'COMPLETE', 'SUCCESS',
          'Total scenarios: $scenarioCount');
    });
  });
}

Future<void> _clearAppState(WidgetTester tester) async {
  // Clear local storage and reset app state
  await tester.binding.defaultBinaryMessenger.send(
    'flutter/platform_views',
    const StandardMethodCodec().encodeMethodCall(
      const MethodCall('clearAppData'),
    ),
  );
}

Future<void> _performDeviceAFlow(WidgetTester tester, int scenarioCount) async {
  // Device A: Generate invite code, create habits, manage changes

  // Navigate to partner settings
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Partner Settings'));
  await tester.pumpAndSettle();

  // Generate invite code
  await tester.tap(find.text('Generate Invite Code'));
  await tester.pumpAndSettle();

  // Take screenshot of invite code
  await _takeScreenshot('device_a_invite_code_$scenarioCount');

  // Navigate to habits
  await tester.tap(find.text('Habits'));
  await tester.pumpAndSettle();

  // Create 3 habits
  for (int i = 1; i <= 3; i++) {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first,
        'Test Habit $i - Scenario $scenarioCount');
    await tester.enterText(
        find.byType(TextField).last, 'Description for habit $i');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle(Duration(seconds: 2));
  }

  // Take screenshot of created habits
  await _takeScreenshot('device_a_habits_created_$scenarioCount');

  // Wait for sync
  await Future.delayed(Duration(seconds: 5));

  // Delete one habit
  await tester.longPress(find.text('Test Habit 1 - Scenario $scenarioCount'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();

  // Edit another habit
  await tester.tap(find.text('Test Habit 2 - Scenario $scenarioCount'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).first,
      'Modified Habit 2 - Scenario $scenarioCount');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();

  // Take final screenshot
  await _takeScreenshot('device_a_final_$scenarioCount');
}

Future<void> _performDeviceBFlow(WidgetTester tester, int scenarioCount) async {
  // Device B: Join partnership, complete habits, verify sync

  // Navigate to partner settings
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Partner Settings'));
  await tester.pumpAndSettle();

  // Enter invite code (simulate getting from device A)
  await tester.tap(find.text('Join Partnership'));
  await tester.pumpAndSettle();

  // Generate a fake invite code for testing
  final fakeInviteCode =
      'FAKE-${Random().nextInt(9999).toString().padLeft(4, '0')}';
  await tester.enterText(find.byType(TextField), fakeInviteCode);
  await tester.tap(find.text('Join'));
  await tester.pumpAndSettle();

  // Take screenshot of partnership status
  await _takeScreenshot('device_b_partnership_$scenarioCount');

  // Navigate to habits
  await tester.tap(find.text('Habits'));
  await tester.pumpAndSettle();

  // Wait for partner habits to sync
  await Future.delayed(Duration(seconds: 5));

  // Take screenshot of synced habits
  await _takeScreenshot('device_b_habits_synced_$scenarioCount');

  // Complete 2 habits (if they exist)
  final habitWidgets = find.byType(CheckboxListTile);
  if (tester.widgetList(habitWidgets).length >= 2) {
    await tester.tap(habitWidgets.first);
    await tester.pumpAndSettle();

    await tester.tap(habitWidgets.at(1));
    await tester.pumpAndSettle();
  }

  // Take screenshot of completed habits
  await _takeScreenshot('device_b_habits_completed_$scenarioCount');

  // Check partner status
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Partner Settings'));
  await tester.pumpAndSettle();

  // Take screenshot of current partners
  await _takeScreenshot('device_b_current_partners_$scenarioCount');
}

Future<void> _logMessage(String filePath, String message) async {
  final timestamp = DateTime.now().toIso8601String();
  final logEntry = '[$timestamp] $message\n';

  final file = File(filePath);
  await file.writeAsString(logEntry, mode: FileMode.append);
}

Future<void> _logCsv(String filePath, String scenario, String action,
    String result, String details) async {
  final timestamp = DateTime.now().toIso8601String();
  final csvEntry =
      '$timestamp,$scenario,$action,$result,"${details.replaceAll('"', '""')}"\n';

  final file = File(filePath);
  await file.writeAsString(csvEntry, mode: FileMode.append);
}

Future<void> _takeScreenshot(String name) async {
  try {
    final result = await Process.run('adb', ['exec-out', 'screencap', '-p']);
    if (result.exitCode == 0) {
      final screenshotFile = File('screenshots/${name}.png');
      await screenshotFile.writeAsBytes(result.stdout);
    }
  } catch (e) {
    print('Failed to take screenshot $name: $e');
  }
}
