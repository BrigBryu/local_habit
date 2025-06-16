import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:habit_level_up/core/auth/auth_service.dart';

// Generate mocks
@GenerateMocks([SupabaseClient, GoTrueClient, User, AuthResponse, Session])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockAuth;
    late MockUser mockUser;
    late MockAuthResponse mockAuthResponse;
    late MockSession mockSession;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockUser = MockUser();
      mockAuthResponse = MockAuthResponse();
      mockSession = MockSession();

      when(mockSupabase.auth).thenReturn(mockAuth);

      authService = AuthService.instance;
    });

    group('Authentication', () {
      test('signUp should create new user successfully', () async {
        // Arrange
        when(mockUser.email).thenReturn('test@example.com');
        when(mockAuthResponse.user).thenReturn(mockUser);
        when(mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockAuthResponse);

        // Act
        final result = await authService.signUp(
          'test@example.com',
          'password123',
          'Test User',
        );

        // Assert
        expect(result.isSuccess, true);
        verify(mockAuth.signUp(
          email: 'test@example.com',
          password: 'password123',
          data: {'display_name': 'Test User'},
        )).called(1);
      });

      test('signIn should authenticate user successfully', () async {
        // Arrange
        when(mockSession.user).thenReturn(mockUser);
        when(mockAuthResponse.session).thenReturn(mockSession);
        when(mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockAuthResponse);

        // Act
        final result = await authService.signIn(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result.isSuccess, true);
        verify(mockAuth.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('signOut should sign out user successfully', () async {
        // Arrange
        when(mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        await authService.signOut();

        // Assert
        verify(mockAuth.signOut()).called(1);
      });

      test('getCurrentUserId should return user ID when authenticated', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');

        // Act
        final userId = authService.getCurrentUserId();

        // Assert
        expect(userId, 'user123');
      });

      test('getCurrentUserId should return null when not authenticated', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final userId = authService.getCurrentUserId();

        // Assert
        expect(userId, null);
      });

      test('isAuthenticated should return true when session exists', () {
        // Arrange
        when(mockAuth.currentSession).thenReturn(mockSession);

        // Act
        final isAuthenticated = authService.isAuthenticated;

        // Assert
        expect(isAuthenticated, true);
      });

      test('isAuthenticated should return false when no session', () {
        // Arrange
        when(mockAuth.currentSession).thenReturn(null);

        // Act
        final isAuthenticated = authService.isAuthenticated;

        // Assert
        expect(isAuthenticated, false);
      });
    });

    group('Error Handling', () {
      test('signUp should handle authentication errors', () async {
        // Arrange
        when(mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          data: anyNamed('data'),
        )).thenThrow(AuthException('Email already registered'));

        // Act
        final result = await authService.signUp(
          'test@example.com',
          'password123',
          'Test User',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Email already registered'));
      });

      test('signIn should handle invalid credentials', () async {
        // Arrange
        when(mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(AuthException('Invalid credentials'));

        // Act
        final result = await authService.signIn(
          'test@example.com',
          'wrongpassword',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Invalid credentials'));
      });
    });
  });
}
