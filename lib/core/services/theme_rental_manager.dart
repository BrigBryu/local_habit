import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Manages theme rental costs with growth(k) taper
class ThemeRentalManager {
  final Logger _logger = Logger();

  /// Growth curve for rental costs based on rental count k
  /// 0:1, 1:2, 2:4, 3:8, 4:16, 5:24, 6:32, 7:40, ≥8:45
  int growth(int k) {
    if (k <= 0) return 1;
    if (k == 1) return 2;
    if (k == 2) return 4;
    if (k == 3) return 8;
    if (k == 4) return 16;
    if (k == 5) return 24;
    if (k == 6) return 32;
    if (k == 7) return 40;
    return 45; // k >= 8
  }

  /// Calculates rental cost for a theme based on previous rentals
  Future<int> calculateRentalCost(String userId, String themeId) async {
    final rentalCount = await _getUserThemeRentalCount(userId, themeId);
    final cost = growth(rentalCount);
    _logger.i('Theme $themeId rental cost for user $userId: $cost (k=$rentalCount)');
    return cost;
  }

  /// Rents a theme and updates rental count
  Future<RentalResult> rentTheme(String userId, String themeId) async {
    try {
      final currentCost = await calculateRentalCost(userId, themeId);
      
      // Check if user has enough coins
      final hasEnoughCoins = await _checkUserCoins(userId, currentCost);
      if (!hasEnoughCoins) {
        return RentalResult(
          success: false,
          message: 'Insufficient coins',
          nextCost: currentCost,
        );
      }

      // Process rental
      await _processRental(userId, themeId, currentCost);
      
      // Calculate next rental cost
      final nextCost = growth(await _getUserThemeRentalCount(userId, themeId));
      
      return RentalResult(
        success: true,
        message: 'Theme rented successfully!',
        nextCost: nextCost,
      );
    } catch (e) {
      _logger.e('Error renting theme: $e');
      return RentalResult(
        success: false,
        message: 'Rental failed: $e',
        nextCost: 1,
      );
    }
  }

  /// Gets user's rental count for a specific theme
  Future<int> _getUserThemeRentalCount(String userId, String themeId) async {
    // Implementation would query database for user_theme rental count
    return 0; // Placeholder
  }

  /// Checks if user has enough coins
  Future<bool> _checkUserCoins(String userId, int cost) async {
    // Implementation would check user's coin balance
    return true; // Placeholder
  }

  /// Processes the rental transaction
  Future<void> _processRental(String userId, String themeId, int cost) async {
    // Implementation would:
    // 1. Deduct coins from user
    // 2. Increment theme rental count
    // 3. Activate theme for user
  }
}

/// Result of a theme rental attempt
class RentalResult {
  final bool success;
  final String message;
  final int nextCost;

  const RentalResult({
    required this.success,
    required this.message,
    required this.nextCost,
  });
}

/// Provider for ThemeRentalManager
final themeRentalManagerProvider = Provider<ThemeRentalManager>(
  (ref) => ThemeRentalManager(),
);