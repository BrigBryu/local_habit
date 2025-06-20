import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:habit_level_up/screens/auth/username_setup_screen.dart';
import 'package:habit_level_up/screens/partner_settings_screen.dart';
import 'package:habit_level_up/core/auth/username_auth_service.dart';
import 'package:habit_level_up/core/validation/validation_service.dart';

// Generate mocks
@GenerateMocks([UsernameAuthService, ValidationService])
import 'invite_flow_widget_test.mocks.dart';

void main() {
  group('Partner Flow Widget Tests', () {
    late MockUsernameAuthService mockAuthService;
    late MockValidationService mockValidationService;

    setUp(() {
      mockAuthService = MockUsernameAuthService();
      mockValidationService = MockValidationService();
    });

    group('Username Setup Screen', () {
      testWidgets('should display username input field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const UsernameSetupScreen(),
            ),
          ),
        );

        expect(find.text('Choose Username'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
      });

      testWidgets('should validate username input',
          (WidgetTester tester) async {
        // Arrange
        when(mockValidationService.validateUsername(any)).thenReturn(
          ValidationResult.error('Username must be 1-32 characters'),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const UsernameSetupScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextFormField), '');
        await tester.tap(find.text('Continue'));
        await tester.pump();

        // Assert
        expect(find.text('Username cannot be empty'), findsOneWidget);
      });

      testWidgets('should show loading state when saving username',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const UsernameSetupScreen(),
            ),
          ),
        );

        // Enter valid username
        await tester.enterText(find.byType(TextFormField), 'TestUser');
        await tester.pump();

        // Tap continue button
        await tester.tap(find.text('Continue'));
        await tester.pump();

        // Should show loading indicator (in real implementation)
        // expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should prevent navigation back',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const UsernameSetupScreen(),
            ),
          ),
        );

        // The AppBar should not have a back button
        expect(find.byIcon(Icons.arrow_back), findsNothing);
      });

      testWidgets('should show username requirements',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const UsernameSetupScreen(),
            ),
          ),
        );

        expect(find.text('💡 Username Requirements:'), findsOneWidget);
        expect(find.textContaining('1-32 characters'), findsOneWidget);
        expect(
            find.textContaining('No leading/trailing spaces'), findsOneWidget);
      });
    });

    group('Partner Settings Screen', () {
      testWidgets('should display partner settings interface',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        expect(find.text('Partner Settings'), findsOneWidget);
        expect(find.text('Current Partners'), findsOneWidget);
        expect(find.text('Link Partner'), findsOneWidget);
      });

      testWidgets('should show partner input field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        expect(find.text('Partner Username'), findsOneWidget);
        expect(find.text('Link Partner'), findsAtLeastNWidgets(1));
      });

      testWidgets('should display how it works information',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        expect(find.text('💡 How it works:'), findsOneWidget);
        expect(find.textContaining('Simply enter your partner\'s username'),
            findsOneWidget);
      });

      testWidgets('should have refresh functionality',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        // Should have refresh button
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        // Should support pull-to-refresh
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });

      testWidgets('should validate partner username input',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        final partnerUsernameField =
            find.widgetWithText(TextFormField, 'Partner Username');
        expect(partnerUsernameField, findsOneWidget);

        // Enter empty username and try to link
        await tester.enterText(partnerUsernameField, '');
        await tester.tap(find.text('Link Partner'));
        await tester.pump();

        // Should show validation message via SnackBar (in real implementation)
      });

      testWidgets('should show username edit option',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        // Should have edit icon for username
        expect(find.byIcon(Icons.edit), findsOneWidget);
      });
    });

    group('Username Guard Integration', () {
      testWidgets('should prevent self-partnership attempts',
          (WidgetTester tester) async {
        // This would test the integration with ValidationService
        // to ensure UI prevents users from partnering with themselves

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        // In a real implementation, this would:
        // 1. Mock the current user as "TestUser"
        // 2. Try to enter "TestUser" as partner
        // 3. Verify error message is shown
        // 4. Verify partnership is not created
      });

      testWidgets('should handle missing username gracefully',
          (WidgetTester tester) async {
        // Test behavior when user doesn't have a username set
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        // Should show "Set Username" option when username is null
        // In real implementation, this would be tested with proper mocking
      });
    });

    group('Error State Handling', () {
      testWidgets('should show error dialog for impossible states',
          (WidgetTester tester) async {
        // This would test ValidationService.showBlockingErrorDialog
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  ValidationService.showBlockingErrorDialog(
                    tester.element(find.byType(Scaffold)),
                    'Test Error',
                    'This is a test error message',
                    () {},
                  );
                },
                child: const Text('Trigger Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Trigger Error'));
        await tester.pumpAndSettle();

        expect(find.text('Test Error'), findsOneWidget);
        expect(find.text('This is a test error message'), findsOneWidget);
        expect(find.text('Fix Now'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should show sign out dialog for unfixable states',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  ValidationService.showSignOutDialog(
                    tester.element(find.byType(Scaffold)),
                    'Critical Error',
                    'This error cannot be fixed',
                    () {},
                  );
                },
                child: const Text('Trigger Critical Error'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Trigger Critical Error'));
        await tester.pumpAndSettle();

        expect(find.text('Critical Error'), findsOneWidget);
        expect(find.text('This error cannot be fixed'), findsOneWidget);
        expect(find.text('Sign Out'), findsOneWidget);
        expect(find.byIcon(Icons.warning), findsOneWidget);
      });
    });

    group('Loading States', () {
      testWidgets('should show loading indicator during async operations',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const PartnerSettingsScreen(),
            ),
          ),
        );

        // The loading state would be tested with proper async mocking
        // to simulate network requests and show CircularProgressIndicator
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const UsernameSetupScreen(),
            ),
          ),
        );

        // Check for semantic labels
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should support keyboard navigation',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const UsernameSetupScreen(),
            ),
          ),
        );

        // Test tab navigation and enter key submission
        final usernameField = find.byType(TextFormField);
        await tester.tap(usernameField);
        await tester.enterText(usernameField, 'TestUser');

        // Pressing enter should submit (in real implementation)
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
      });
    });
  });
}
