import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/streak_points_provider.dart';
import '../../../../providers/habits_provider.dart';
import '../../../../core/repositories/local_habits_repository.dart';
import 'streak_points_notification.dart';

class StreakNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const StreakNotificationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<StreakNotificationListener> createState() => _StreakNotificationListenerState();
}

class _StreakNotificationListenerState extends ConsumerState<StreakNotificationListener> {
  @override
  void initState() {
    super.initState();
    
    // Listen to streak rewards from the repository
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repository = ref.read(habitsRepositoryProvider);
      if (repository is LocalHabitsRepository) {
        repository.lastStreakReward.listen((rewardData) {
          if (rewardData != null && mounted) {
            StreakPointsNotification.show(
              context,
              ref,
              points: rewardData.points,
              streakLength: rewardData.streakLength,
              habitName: rewardData.habitName,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}