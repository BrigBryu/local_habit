import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_level_up/main.dart' as app;
import 'package:habit_level_up/core/network/supabase_client.dart';
import 'package:habit_level_up/core/network/partner_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Partner Flow Integration Tests', () {
    late String deviceAUserId;
    late String deviceBUserId;
    const String deviceAUsername = 'device_a_test';
    const String deviceBUsername = 'device_b_test';

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

    testWidgets('Device A can send partner request to Device B', (WidgetTester tester) async {
      // Sign in as Device A
      await _signInAsDevice('A');
      deviceAUserId = supabase.auth.currentUser!.id;
      expect(deviceAUserId, isNotNull);

      // Launch app
      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      // Navigate to Partner Settings
      await _navigateToPartnerSettings(tester);

      // Enter Device B's username
      final usernameField = find.widgetWithText(TextFormField, 'Partner Username');
      await tester.enterText(usernameField, deviceBUsername);
      await tester.pumpAndSettle();

      // Tap Link Partner button
      await tester.tap(find.text('Link Partner'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.textContaining('Successfully'), findsOneWidget);

      print('Device A sent partner request to: $deviceBUsername');
    });

    testWidgets('Device B confirms partnership exists',
        (WidgetTester tester) async {
      // Sign in as Device B
      await _signInAsDevice('B');
      deviceBUserId = supabase.auth.currentUser!.id;
      expect(deviceBUserId, isNotNull);
      expect(deviceBUserId, isNot(equals(deviceAUserId)),
          reason: 'Device B should have different user ID');

      // Check partnership exists via service
      final partners = await PartnerService.instance.getPartners();
      expect(partners.isNotEmpty, isTrue, 
          reason: 'Device B should have at least one partner');

      // Launch app
      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      // Navigate to Partner Settings
      await _navigateToPartnerSettings(tester);

      // Should show partner in the list
      expect(find.textContaining('Current Partners'), findsOneWidget);
      expect(find.text('No partners linked yet'), findsNothing);

      print('Device B confirmed partnership with Device A');
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

    testWidgets('Cannot link to non-existent username', (WidgetTester tester) async {
      // Sign in as Device A
      await _signInAsDevice('A');

      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      await _navigateToPartnerSettings(tester);

      // Try to link to non-existent username
      final usernameField = find.widgetWithText(TextFormField, 'Partner Username');
      await tester.enterText(usernameField, 'nonexistent_user_12345');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Link Partner'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('not found'), findsOneWidget);
    });

    testWidgets('Cannot link to yourself', (WidgetTester tester) async {
      // Sign in as Device A
      await _signInAsDevice('A');

      await tester.pumpWidget(const app.HabitLevelUpApp());
      await tester.pumpAndSettle();

      await _navigateToPartnerSettings(tester);

      // Try to link to own username
      final usernameField = find.widgetWithText(TextFormField, 'Partner Username');
      await tester.enterText(usernameField, deviceAUsername);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Link Partner'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Cannot link to yourself'), findsOneWidget);
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

    testWidgets('Direct partner service API test',
        (WidgetTester tester) async {
      // Test the PartnerService directly
      await _signInAsDevice('A');
      
      try {
        // This should work - linking to Device B
        await PartnerService.instance.linkPartner(deviceBUsername);
        print('Direct API: Successfully linked to $deviceBUsername');
      } catch (e) {
        print('Direct API: Error linking to $deviceBUsername: $e');
        // This might fail if already linked, which is OK
      }

      // Test getting partners
      final partners = await PartnerService.instance.getPartners();
      print('Direct API: Found ${partners.length} partners');
      
      for (final partner in partners) {
        print('Partner: ${partner.partnerUsername} (ID: ${partner.partnerId})');
      }
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
  expect(find.text('Link Partner'), findsOneWidget);
}

/// Helper function to reset test database
Future<void> _resetTestDatabase() async {
  // Clean up relationships for test users
  try {
    await supabase
        .from('relationships')
        .delete()
        .neq('id', '00000000-0000-0000-0000-000000000000');
    
    print('Test database reset completed');
  } catch (e) {
    print('Test database reset error (might be expected): $e');
  }
}
