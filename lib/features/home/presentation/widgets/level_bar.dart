import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/flexible_theme_system.dart';

class AnimatedLevelBar extends ConsumerWidget {
  final VoidCallback? onTap;

  const AnimatedLevelBar({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final levelService = LevelService();
    final level = levelService.currentLevel;
    final currentXP = levelService.currentXP;
    final nextLevelXP = levelService.xpForNextLevel;
    final progress = (currentXP / nextLevelXP).clamp(0.0, 1.0);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isMobile ? 32 : 60,
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 16,
          vertical: isMobile ? 1 : 8,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 0 : 12,
        ),
        decoration: BoxDecoration(
          color: colors.draculaCurrentLine,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.primaryPurple.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primaryPurple.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isMobile ? 28 : 36,
              height: isMobile ? 28 : 36,
              decoration: BoxDecoration(
                color: colors.primaryPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
              ),
              child: Icon(
                Icons.star,
                color: colors.primaryPurple,
                size: isMobile ? 16 : 20,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: ClipRect(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level $level',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 16,
                        fontWeight: FontWeight.bold,
                        color: colors.draculaForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 0 : 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Container(
                            height: isMobile ? 4 : 6,
                            child: Stack(
                              children: [
                                Container(
                                  height: isMobile ? 4 : 6,
                                  decoration: BoxDecoration(
                                    color:
                                        colors.draculaComment.withOpacity(0.3),
                                    borderRadius:
                                        BorderRadius.circular(isMobile ? 2 : 3),
                                  ),
                                ),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeInOut,
                                  tween: Tween(begin: 0.0, end: progress),
                                  builder: (context, animatedProgress, child) {
                                    return FractionallySizedBox(
                                      widthFactor: animatedProgress,
                                      child: Container(
                                        height: isMobile ? 4 : 6,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              colors.primaryPurple,
                                              colors.completedBackground,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              isMobile ? 2 : 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colors.primaryPurple
                                                  .withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 4 : 8),
                        Flexible(
                          child: Text(
                            '$currentXP / $nextLevelXP XP',
                            style: TextStyle(
                              fontSize: isMobile ? 7 : 12,
                              color: colors.draculaComment,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.draculaComment,
              size: isMobile ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the old LevelBar for backward compatibility
class LevelBar extends StatelessWidget {
  final VoidCallback? onTap;

  const LevelBar({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedLevelBar(onTap: onTap);
  }
}
