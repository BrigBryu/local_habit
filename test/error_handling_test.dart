import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_level_up/core/error/error_handler.dart';

void main() {
  group('Error Handling', () {
    group('Result', () {
      test('should create successful result', () {
        final result = Result.success('data');

        expect(result.isSuccess, true);
        expect(result.data, 'data');
        expect(result.error, null);
      });

      test('should create failure result', () {
        final result = Result<String>.failure('error message');

        expect(result.isSuccess, false);
        expect(result.data, null);
        expect(result.error, 'error message');
      });

      test('unwrap should return data for successful result', () {
        final result = Result.success(42);

        expect(result.unwrap(), 42);
      });

      test('unwrap should throw for failure result', () {
        final result = Result<int>.failure('error');

        expect(() => result.unwrap(), throwsException);
      });

      test('map should transform successful result', () {
        final result = Result.success(5);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isSuccess, true);
        expect(mapped.data, 10);
      });

      test('map should preserve failure result', () {
        final result = Result<int>.failure('error');
        final mapped = result.map((value) => value * 2);

        expect(mapped.isSuccess, false);
        expect(mapped.error, 'error');
      });

      test('flatMap should chain successful results', () {
        final result = Result.success(5);
        final mapped = result.flatMap((value) => Result.success(value * 2));

        expect(mapped.isSuccess, true);
        expect(mapped.data, 10);
      });

      test('flatMap should handle chained failures', () {
        final result = Result.success(5);
        final mapped =
            result.flatMap((value) => Result<int>.failure('chained error'));

        expect(mapped.isSuccess, false);
        expect(mapped.error, 'chained error');
      });
    });

    group('safeCall', () {
      test('should return success for successful operation', () async {
        final result = await safeCall(() async => 'success');

        expect(result.isSuccess, true);
        expect(result.data, 'success');
      });

      test('should handle exceptions and return failure', () async {
        final result =
            await safeCall(() async => throw Exception('test error'));

        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
      });

      test('should provide user-friendly error messages', () async {
        // Test timeout error
        var result = await safeCall(() async =>
            throw TimeoutException('timeout', Duration(seconds: 5)));
        expect(result.error, contains('timed out'));

        // Test network error
        result = await safeCall(() async => throw Exception('network error'));
        expect(result.error, contains('Network error'));

        // Test permission error
        result =
            await safeCall(() async => throw Exception('unauthorized access'));
        expect(result.error, contains('Permission denied'));

        // Test generic error
        result = await safeCall(() async => throw Exception('random error'));
        expect(result.error, contains('unexpected error'));
      });

      test('should include context in error logging', () async {
        final result = await safeCall(
          () async => throw Exception('test error'),
          context: 'test context',
        );

        expect(result.isSuccess, false);
        // Context would be logged but not returned in user message
        expect(result.error, isNotNull);
      });
    });

    group('safeSyncCall', () {
      test('should return success for successful operation', () {
        final result = safeSyncCall(() => 'success');

        expect(result.isSuccess, true);
        expect(result.data, 'success');
      });

      test('should handle exceptions and return failure', () {
        final result = safeSyncCall(() => throw Exception('test error'));

        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
      });

      test('should work with different return types', () {
        // Test with int
        var intResult = safeSyncCall(() => 42);
        expect(intResult.isSuccess, true);
        expect(intResult.data, 42);

        // Test with bool
        var boolResult = safeSyncCall(() => true);
        expect(boolResult.isSuccess, true);
        expect(boolResult.data, true);

        // Test with custom object
        var listResult = safeSyncCall(() => [1, 2, 3]);
        expect(listResult.isSuccess, true);
        expect(listResult.data, [1, 2, 3]);
      });
    });

    group('Extension Methods', () {
      test('Future.safe should work correctly', () async {
        // Test successful future
        final successFuture = Future.value(42);
        final result = await successFuture.safe();

        expect(result.isSuccess, true);
        expect(result.data, 42);
      });

      test('Future.safe should handle exceptions', () async {
        // Test failing future
        final failingFuture = Future<int>.error('test error');
        final result = await failingFuture.safe();

        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
      });

      test('Function.safe should work correctly', () {
        // Test successful function
        int successFunction() => 42;
        final result = successFunction.safe();

        expect(result.isSuccess, true);
        expect(result.data, 42);
      });

      test('Function.safe should handle exceptions', () {
        // Test failing function
        int failingFunction() => throw Exception('test error');
        final result = failingFunction.safe();

        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
      });
    });

    group('Error Message Classification', () {
      test('should classify timeout errors correctly', () async {
        final result = await safeCall(() async {
          throw TimeoutException('operation timeout', Duration(seconds: 30));
        });

        expect(result.error, contains('timed out'));
        expect(result.error, contains('connection'));
      });

      test('should classify network errors correctly', () async {
        final networkErrors = [
          'network error',
          'connection failed',
          'socket exception',
          'network timeout',
        ];

        for (final errorMsg in networkErrors) {
          final result = await safeCall(() async => throw Exception(errorMsg));
          expect(result.error, contains('Network error'));
        }
      });

      test('should classify permission errors correctly', () async {
        final permissionErrors = [
          'permission denied',
          'unauthorized access',
          'unauthorized',
          'forbidden',
        ];

        for (final errorMsg in permissionErrors) {
          final result = await safeCall(() async => throw Exception(errorMsg));
          expect(result.error, contains('Permission denied'));
        }
      });
    });
  });
}
