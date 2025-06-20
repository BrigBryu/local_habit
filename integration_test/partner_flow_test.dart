import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_level_up/main.dart' as app;
import 'package:habit_level_up/core/network/supabase_client.dart';
import 'package:habit_level_up/core/network/relationship_dto.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Partner Flow Integration Tests', () {
    late String deviceAUserId;
    late String deviceBUserId;
    late String inviteCode;

    setUpAll(() async {
      // Load test environment
      await dotenv.load(fileName: '.env.dev');

      // Initialize Supabase
      await SupabaseClientService.instance.initialize();


      // Reset database state
      await _resetTestDatabase();
    });

    setUp(() async {
      // Sign out any existing sessions
      await supabase.auth.signOut();
    });

    testWidgets('Device A can create invite code', (WidgetTester tester) async {
      // Sign in as Device A
      await _signInAsDevice('A');
      deviceAUserId = supabase.auth.currentUser!.id;
      expect(deviceAUserId, isNotNull);

      // Launch app
      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      // Navigate to Partner Settings
      await _navigateToPartnerSettings(tester);

      // Create invite code
      await tester.tap(find.text('Create Invite Code'));
      await tester.pumpAndSettle();

      // Should show success message and invite code
      expect(find.textContaining('Invite code created:'), findsOneWidget);

      // Extract the invite code from the UI
      final inviteCodeText = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .firstWhere(
              (text) =>
                  text != null && RegExp(r'^[A-Z0-9]{6}$').hasMatch(text!),
              orElse: () => null);

      expect(inviteCodeText, isNotNull);
      inviteCode = inviteCodeText!;

      print('Created invite code: $inviteCode');
    });

    testWidgets('Device B can link with invite code',
        (WidgetTester tester) async {
      expect(inviteCode, isNotNull,
          reason: 'Previous test should have created invite code');

      // Sign in as Device B
      await _signInAsDevice('B');
      deviceBUserId = supabase.auth.currentUser!.id;
      expect(deviceBUserId, isNotNull);
      expect(deviceBUserId, isNot(equals(deviceAUserId)),
          reason: 'Device B should have different user ID');

      // Launch app
      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      // Navigate to Partner Settings
      await _navigateToPartnerSettings(tester);

      // Enter invite code
      final codeField = find.byType(TextField).last;
      await tester.enterText(codeField, inviteCode);
      await tester.pumpAndSettle();

      // Tap Link Partner button
      await tester.tap(find.text('Link Partner'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Successfully linked to partner!'), findsOneWidget);
    });

    testWidgets('Both devices show partner relationship',
        (WidgetTester tester) async {
      // Test Device A sees the relationship
      await _signInAsDevice('A');
      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      await _navigateToPartnerSettings(tester);

      // Should show partner in the list
      expect(find.textContaining('Partner'), findsWidgets);
      expect(find.text('No partners linked yet'), findsNothing);

      // Test Device B sees the relationship
      await _signInAsDevice('B');
      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      await _navigateToPartnerSettings(tester);

      // Should show partner in the list
      expect(find.textContaining('Partner'), findsWidgets);
      expect(find.text('No partners linked yet'), findsNothing);
    });

    testWidgets('Cannot reuse same invite code', (WidgetTester tester) async {
      // Try to create a new device and use the same code
      await _signInAsDevice('A'); // Different from the one that used it

      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      await _navigateToPartnerSettings(tester);

      // Try to use the same invite code again
      final codeField = find.byType(TextField).last;
      await tester.enterText(codeField, inviteCode);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Link Partner'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Invalid or expired'), findsOneWidget);
    });

    testWidgets('Cannot link to yourself', (WidgetTester tester) async {
      // Sign in as Device A
      await _signInAsDevice('A');

      // Create a new invite code
      final newCode = await PartnerService.instance.createInviteCode();
      expect(newCode.success, isTrue);

      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      await _navigateToPartnerSettings(tester);

      // Try to use own invite code
      final codeField = find.byType(TextField).last;
      await tester.enterText(codeField, newCode.inviteCode!);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Link Partner'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Cannot link to yourself'), findsOneWidget);
    });

    testWidgets('Database contains correct relationship records',
        (WidgetTester tester) async {
      // Query database directly to verify relationships
      final relationships =
          await supabase.from('relationships').select().eq('status', 'active');

      // Should have 2 records (bidirectional)
      expect(relationships.length, equals(2));

      // Verify the relationships are correctly linked
      final userIds = relationships.map((r) => r['user_id']).toSet();
      final partnerIds = relationships.map((r) => r['partner_id']).toSet();

      expect(userIds, contains(deviceAUserId));
      expect(userIds, contains(deviceBUserId));
      expect(partnerIds, contains(deviceAUserId));
      expect(partnerIds, contains(deviceBUserId));

      // Verify bidirectional relationship
      final aToB = relationships.firstWhere(
        (r) =>
            r['user_id'] == deviceAUserId && r['partner_id'] == deviceBUserId,
      );
      final bToA = relationships.firstWhere(
        (r) =>
            r['user_id'] == deviceBUserId && r['partner_id'] == deviceAUserId,
      );

      expect(aToB, isNotNull);
      expect(bToA, isNotNull);
    });

    testWidgets('Race condition: simultaneous link attempts',
        (WidgetTester tester) async {
      // Reset state for this test
      await _resetTestDatabase();

      // Create new invite code
      await _signInAsDevice('A');
      final codeResult = await PartnerService.instance.createInviteCode();
      expect(codeResult.success, isTrue);
      final raceCode = codeResult.inviteCode!;

      // Sign in as Device B
      await _signInAsDevice('B');

      // Attempt to link with the same code simultaneously
      final futures = [
        PartnerService.instance.linkPartner(raceCode),
        PartnerService.instance.linkPartner(raceCode),
      ];

      final results = await Future.wait(futures);

      // Only one should succeed
      final successCount = results.where((r) => r.success).length;
      expect(successCount, equals(1),
          reason: 'Only one link attempt should succeed');

      final failureCount = results.where((r) => !r.success).length;
      expect(failureCount, equals(1), reason: 'One link attempt should fail');
    });
  });
}

/// Helper function to sign in as a specific device
Future<void> _signInAsDevice(String device) async {
  await supabase.auth.signOut();

  final email =
      device == 'B' ? dotenv.env['TEST_EMAIL_B'] : dotenv.env['TEST_EMAIL_A'];
  final password = device == 'B'
      ? dotenv.env['TEST_PASSWORD_B']
      : dotenv.env['TEST_PASSWORD_A'];

  final response = await supabase.auth.signInWithPassword(
    email: email!,
    password: password!,
  );

  expect(response.session, isNotNull);
  print('Signed in as device $device: ${response.user?.email}');
}

/// Helper function to navigate to Partner Settings screen
Future<void> _navigateToPartnerSettings(WidgetTester tester) async {
  // Look for the settings/partner navigation element
  // This will depend on your app's navigation structure

  // If there's a bottom navigation
  final settingsTab = find.byIcon(Icons.settings);
  if (settingsTab.hasFound) {
    await tester.tap(settingsTab);
    await tester.pumpAndSettle();
  }

  // Look for Partner Settings option
  final partnerSettings = find.text('Partner Settings');
  if (partnerSettings.hasFound) {
    await tester.tap(partnerSettings);
    await tester.pumpAndSettle();
  } else {
    // Alternative: look for partner-related text or icons
    final partnerIcon = find.byIcon(Icons.people);
    if (partnerIcon.hasFound) {
      await tester.tap(partnerIcon);
      await tester.pumpAndSettle();
    }
  }

  // Verify we're on the partner settings screen
  expect(find.text('Create Invite Code'), findsOneWidget);
}

/// Helper function to reset test database
Future<void> _resetTestDatabase() async {
  // Execute the dev reset script
  await supabase.rpc('exec_sql', params: {
    'sql': '''
      truncate table public.relationships cascade;
      truncate table public.invite_codes cascade;
    '''
  }).catchError((e) {
    // If the RPC doesn't exist, do manual cleanup
    return Future.wait([
      supabase
          .from('relationships')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000'),
      supabase
          .from('invite_codes')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000'),
    ]);
  });

  print('Test database reset completed');
}
