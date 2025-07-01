import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/flexible_theme_system.dart';
import '../../../../providers/streak_points_provider.dart';
import '../../../../providers/habits_provider.dart';

class BalanceChip extends ConsumerWidget {
  final bool showLabel;
  final double? size;

  const BalanceChip({
    super.key,
    this.showLabel = true,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final habitsRepository = ref.watch(habitsRepositoryProvider);
    final userId = habitsRepository.getCurrentUserId();
    final balanceAsync = ref.watch(walletBalanceProvider(userId));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size != null ? size! * 0.6 : 12,
        vertical: size != null ? size! * 0.4 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryPurple.withOpacity(0.2),
            colors.primaryPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size != null ? size! * 1.2 : 20),
        border: Border.all(
          color: colors.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond,
            color: colors.primaryPurple,
            size: size ?? 18,
          ),
          SizedBox(width: size != null ? size! * 0.3 : 6),
          balanceAsync.when(
            data: (balance) => Text(
              balance.toString(),
              style: TextStyle(
                color: colors.primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: size != null ? size! * 0.9 : 16,
              ),
            ),
            loading: () => SizedBox(
              width: size ?? 16,
              height: size ?? 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(colors.primaryPurple),
              ),
            ),
            error: (_, __) => Text(
              '0',
              style: TextStyle(
                color: colors.draculaRed,
                fontWeight: FontWeight.bold,
                fontSize: size != null ? size! * 0.9 : 16,
              ),
            ),
          ),
          if (showLabel) ...[
            SizedBox(width: size != null ? size! * 0.3 : 6),
            Text(
              'points',
              style: TextStyle(
                color: colors.primaryPurple.withOpacity(0.8),
                fontSize: size != null ? size! * 0.7 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}