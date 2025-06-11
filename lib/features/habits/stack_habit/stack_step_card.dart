import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/stack_service.dart';
import '../../../providers/habits_provider.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/flexible_theme_system.dart';

const Duration kCompletionAnimationDuration = Duration(milliseconds: 600);
const Duration kSlideAnimationDuration = Duration(milliseconds: 400);

/// Focused step card component for single-step habit stack UI
class StackStepCard extends ConsumerStatefulWidget {
  final Habit stack;
  final List<Habit> allHabits;

  const StackStepCard({
    super.key,
    required this.stack,
    required this.allHabits,
  });

  @override
  ConsumerState<StackStepCard> createState() => _StackStepCardState();
}

class _StackStepCardState extends ConsumerState<StackStepCard>
    with TickerProviderStateMixin {
  final _stackService = StackService();
  late AnimationController _slideController;
  late AnimationController _flipController;
  late AnimationController _confettiController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: kSlideAnimationDuration,
      vsync: this,
    );
    
    _flipController = AnimationController(
      duration: kCompletionAnimationDuration,
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));

    // Start initial slide-in animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _flipController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextStep = _stackService.getNextIncompleteStep(widget.stack, widget.allHabits);
    final progress = _stackService.getStackProgress(widget.stack, widget.allHabits);
    final isCompleted = _stackService.isStackCompleted(widget.stack, widget.allHabits);

    if (nextStep == null && isCompleted) {
      return _buildCompletionCard(progress);
    }

    if (nextStep == null) {
      return _buildEmptyStackCard();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: _flipAnimation.value < 0.5
                ? Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildStepCard(nextStep, progress),
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildCheckmarkCard(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard(Habit step, StackProgress progress) {
    final colors = ref.watchColors;
    final remaining = progress.total - progress.completed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colors.stackHabit.withOpacity(0.15),
            colors.stackHabit.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.stackHabit.withOpacity(0.4),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.stackHabit.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stack badge
            _buildStackBadge(progress, remaining, colors),
            // Step content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step title
                  Text(
                    step.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.stackHabit,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (step.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.draculaCyan,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Complete button
                  _buildCompleteButton(step, colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackBadge(StackProgress progress, int remaining, FlexibleColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.stackHabit.withOpacity(0.3),
            colors.stackHabit.withOpacity(0.2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.stackHabit,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.stackHabit.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.layers,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${progress.position} / ${progress.total}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$remaining left',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(Habit step, FlexibleColors colors) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.stackHabit,
            colors.stackHabit.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.stackHabit.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _completeStep(step),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Mark Complete',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckmarkCard() {
    final colors = ref.watchColors;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colors.success.withOpacity(0.2),
            colors.success.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.success.withOpacity(0.4),
          width: 3,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.check_circle,
          size: 80,
          color: colors.success,
        ),
      ),
    );
  }

  Widget _buildCompletionCard(StackProgress progress) {
    final colors = ref.watchColors;
    
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                colors.success.withOpacity(0.3),
                colors.success.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colors.success.withOpacity(0.6),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.success.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              children: [
                // Confetti effect
                if (_confettiAnimation.value > 0)
                  _buildConfettiEffect(colors),
                // Content
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.military_tech,
                        size: 64,
                        color: colors.success,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stack Complete!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.success,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All ${progress.total} steps completed',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.draculaCyan,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${widget.stack.calculateXPReward() + 2} XP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStackCard() {
    final colors = ref.watchColors;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colors.draculaComment.withOpacity(0.1),
            colors.draculaComment.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.draculaComment.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers_clear,
              size: 48,
              color: colors.draculaComment,
            ),
            const SizedBox(height: 16),
            Text(
              'Empty Stack',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.draculaComment,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add some steps to get started',
              style: TextStyle(
                fontSize: 16,
                color: colors.draculaComment.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiEffect(FlexibleColors colors) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ConfettiPainter(
          animation: _confettiAnimation,
          colors: [
            colors.success,
            colors.stackHabit,
            colors.draculaPink,
            colors.draculaCyan,
          ],
        ),
      ),
    );
  }

  void _completeStep(Habit step) async {
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final colors = ref.watchColors;
    
    // Start flip animation
    await _flipController.forward();
    
    // Complete the habit
    final result = habitsNotifier.completeHabit(step.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: colors.error,
        ),
      );
      _flipController.reverse();
      return;
    }

    // Check if this was the last step
    final progress = _stackService.getStackProgress(widget.stack, widget.allHabits);
    final isLastStep = progress.completed >= progress.total;

    if (isLastStep) {
      // Start confetti animation for stack completion
      _confettiController.forward();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Stack completed! +${widget.stack.calculateXPReward() + 2} XP'),
          backgroundColor: colors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Show step completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${step.name} completed! +${step.calculateXPReward()} XP'),
          backgroundColor: colors.success,
        ),
      );
      
      // Slide to next step after a delay
      await Future.delayed(const Duration(milliseconds: 1000));
      _flipController.reset();
      _slideController.reset();
      _slideController.forward();
    }
  }
}

/// Custom painter for confetti effect
class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  ConfettiPainter({required this.animation, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      final progress = (animation.value + i * 0.1) % 1.0;
      final x = (i * 0.1 * size.width + progress * size.width * 0.3) % size.width;
      final y = progress * size.height;
      final colorIndex = i % colors.length;
      
      paint.color = colors[colorIndex].withOpacity(1.0 - progress);
      
      canvas.drawCircle(
        Offset(x, y),
        4.0 * (1.0 - progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}