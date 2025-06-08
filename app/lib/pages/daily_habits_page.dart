import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habits_provider.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/timed_habit_service.dart';
import 'package:data_local/repositories/bundle_service.dart';
import '../screens/create_bundle_screen.dart';

class DailyHabitsPage extends ConsumerWidget {
  const DailyHabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabits = ref.watch(habitsProvider);
    
    // Filter to show only top-level habits (not children of bundles)
    final topLevelHabits = allHabits.where((habit) => 
      habit.parentBundleId == null
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Habits'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: topLevelHabits.isEmpty
          ? const Center(
              child: Text(
                'No habits yet!\nTap the + button to add your first habit.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: topLevelHabits.length,
              itemBuilder: (context, index) {
                final habit = topLevelHabits[index];
                print('Top-level habit: ${habit.name}, Type: ${habit.type}'); // Debug
                if (habit.type == HabitType.bundle) {
                  print('Rendering SmartBundle card for: ${habit.name}'); // Debug
                  return SmartBundleCard(habit: habit, allHabits: allHabits);
                } else {
                  return IndividualHabitCard(habit: habit);
                }
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "bundle",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateBundleScreen(),
                ),
              );
            },
            tooltip: 'Create Bundle',
            child: const Icon(Icons.folder),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "sample",
            onPressed: () {
              // Add some sample habits for testing
              final habitsNotifier = ref.read(habitsProvider.notifier);
              
              // Add a basic habit
              habitsNotifier.addHabit(Habit.create(
                name: 'Read 30 minutes',
                description: 'Daily reading habit',
                type: HabitType.basic,
              ));
              
              // Add a timed session habit
              habitsNotifier.addHabit(Habit.create(
                name: 'Meditation',
                description: '10 minute meditation session',
                type: HabitType.timedSession,
                timeoutMinutes: 10,
              ));
              
              // Add a daily time window habit
              habitsNotifier.addHabit(Habit.create(
                name: 'Morning Workout',
                description: 'Exercise during morning hours',
                type: HabitType.dailyTimeWindow,
                windowStartTime: const TimeOfDay(hour: 6, minute: 0),
                windowEndTime: const TimeOfDay(hour: 10, minute: 0),
              ));
              
              // Add an avoidance habit
              habitsNotifier.addHabit(Habit.create(
                name: 'No Social Media',
                description: 'Avoid mindless scrolling',
                type: HabitType.avoidance,
              ));
              
              // Add individual habits that will be bundled
              final bedHabit = Habit.create(
                name: 'Make Bed',
                description: 'Make your bed each morning',
                type: HabitType.basic,
              );
              final waterHabit = Habit.create(
                name: 'Drink Water',
                description: 'Drink a glass of water',
                type: HabitType.basic,
              );
              final stretchHabit = Habit.create(
                name: 'Stretch',
                description: '5 minute stretch',
                type: HabitType.basic,
              );
              
              habitsNotifier.addHabit(bedHabit);
              habitsNotifier.addHabit(waterHabit);
              habitsNotifier.addHabit(stretchHabit);
              
              // Create a bundle with these habits
              habitsNotifier.addBundle(
                'Morning Routine',
                'Complete your morning routine',
                [bedHabit.id, waterHabit.id, stretchHabit.id],
              );
            },
            tooltip: 'Add Sample Habits',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

/// Individual habit card for standalone habits (not in bundles)
class IndividualHabitCard extends ConsumerWidget {
  final Habit habit;
  
  const IndividualHabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: HabitListTile(habit: habit),
    );
  }
}

/// Internal habit list tile widget (reusable for both individual and nested habits)
class HabitListTile extends ConsumerWidget {
  final Habit habit;
  final bool isNested;
  final EdgeInsets? padding;
  
  const HabitListTile({
    super.key, 
    required this.habit,
    this.isNested = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timedHabitService = TimedHabitService();
    final isCompleted = _isHabitCompletedToday(habit);
    
    return Container(
      padding: padding ?? (isNested ? const EdgeInsets.only(left: 16) : EdgeInsets.zero),
      decoration: isNested ? BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 3,
          ),
        ),
      ) : null,
      child: ListTile(
        contentPadding: isNested 
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
          : null,
        title: Text(
          habit.displayName,
          style: TextStyle(
            fontSize: isNested ? 14 : 16,
            fontWeight: isNested ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _getSubtitle(timedHabitService),
          style: TextStyle(
            fontSize: isNested ? 12 : 14,
          ),
        ),
        trailing: _buildTrailingIcon(context, ref, timedHabitService, isCompleted),
        onTap: habit.type == HabitType.avoidance ? null : () => _handleTap(context, ref, timedHabitService),
      ),
    );
  }

  String _getSubtitle(TimedHabitService timedHabitService) {
    if (habit.type == HabitType.timedSession ||
        habit.type == HabitType.timeWindow ||
        habit.type == HabitType.dailyTimeWindow ||
        habit.type == HabitType.alarmHabit) {
      return timedHabitService.getTimedHabitStatus(habit);
    }
    
    // For basic habits, show completion count if > 0
    if (habit.type == HabitType.basic && habit.dailyCompletionCount > 0) {
      final count = habit.dailyCompletionCount;
      final nextXP = habit.calculateXPReward();
      return 'Completed ${count}x today • Next: +${nextXP} XP';
    }
    
    // For avoidance habits, show status
    if (habit.type == HabitType.avoidance) {
      if (habit.avoidanceSuccessToday) {
        return 'Successfully avoided today!';
      } else if (habit.dailyFailureCount > 0) {
        return 'Failed ${habit.dailyFailureCount}x today';
      } else {
        return 'Tap ✅ if avoided, ❌ if failed';
      }
    }
    
    return habit.description;
  }

  Widget _buildTrailingIcon(BuildContext context, WidgetRef ref, 
      TimedHabitService timedHabitService, bool isCompleted) {
    
    if (isCompleted && habit.type != HabitType.avoidance) {
      return const Icon(Icons.check_box, color: Colors.green);
    }

    switch (habit.type) {
      case HabitType.timedSession:
        // Show timer icon if session not started, or clock if running
        if (timedHabitService.isSessionActive(habit.id)) {
          return const Icon(Icons.timer, color: Colors.orange);
        } else if (habit.sessionCompletedToday) {
          return const Icon(Icons.check_box_outline_blank, color: Colors.blue);
        } else if (habit.hasStartedSessionToday()) {
          return const Icon(Icons.timer_off, color: Colors.grey);
        } else {
          return const Icon(Icons.play_circle_outline, color: Colors.blue);
        }
      
      case HabitType.timeWindow:
      case HabitType.dailyTimeWindow:
        if (timedHabitService.isTimeWindowAvailable(habit)) {
          return const Icon(Icons.check_box_outline_blank, color: Colors.green);
        } else {
          return const Icon(Icons.schedule, color: Colors.grey);
        }
      
      case HabitType.alarmHabit:
        if (timedHabitService.isTimedHabitActive(habit.id)) {
          return const Icon(Icons.alarm, color: Colors.red);
        } else {
          return const Icon(Icons.alarm_off, color: Colors.grey);
        }
      
      case HabitType.avoidance:
        return AvoidanceHabitButtons(habit: habit, ref: ref);
      
      default:
        return const Icon(Icons.check_box_outline_blank);
    }
  }

  bool _isHabitCompletedToday(Habit habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted!;
    return now.year == lastCompleted.year &&
           now.month == lastCompleted.month &&
           now.day == lastCompleted.day;
  }

  void _handleTap(BuildContext context, WidgetRef ref, TimedHabitService timedHabitService) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    
    if (_isHabitCompletedToday(habit)) {
      return; // Already completed
    }

    switch (habit.type) {
      case HabitType.timedSession:
        if (!habit.hasStartedSessionToday()) {
          // Start the timer
          final result = habitsNotifier.startTimedSession(habit.id);
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Timer started for ${habit.name}!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Timer already started today')),
            );
          }
        } else if (habit.sessionCompletedToday) {
          // Check off the completed session
          final result = habitsNotifier.completeHabit(habit.id);
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${habit.name} completed!')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Timer still running or not completed')),
          );
        }
        break;
      
      case HabitType.timeWindow:
      case HabitType.dailyTimeWindow:
        final validationError = timedHabitService.validateTimeWindowCompletion(habit);
        if (validationError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(validationError)),
          );
        } else {
          final result = habitsNotifier.completeHabit(habit.id);
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${habit.name} completed!')),
            );
          }
        }
        break;
      
      default:
        final result = habitsNotifier.completeHabit(habit.id);
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${habit.name} completed!')),
          );
        }
    }
  }
}

class AvoidanceHabitButtons extends ConsumerWidget {
  final Habit habit;
  final WidgetRef ref;

  const AvoidanceHabitButtons({super.key, required this.habit, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (habit.avoidanceSuccessToday) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 32);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Failure button
        GestureDetector(
          onTap: () => _recordFailure(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Icon(Icons.close, color: Colors.red, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        // Success button
        GestureDetector(
          onTap: () => _markSuccess(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 24),
          ),
        ),
      ],
    );
  }

  void _recordFailure(BuildContext context) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.recordFailure(habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  void _markSuccess(BuildContext context) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.completeHabit(habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${habit.name} avoided successfully!')),
      );
    }
  }
}

/// Smart bundle card that shows nested children with proper hierarchy
class SmartBundleCard extends ConsumerStatefulWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const SmartBundleCard({super.key, required this.habit, required this.allHabits});

  @override
  ConsumerState<SmartBundleCard> createState() => _SmartBundleCardState();
}

class _SmartBundleCardState extends ConsumerState<SmartBundleCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  final _bundleService = BundleService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _bundleService.getBundleProgress(widget.habit, widget.allHabits);
    final isCompleted = _bundleService.isBundleCompleted(widget.habit, widget.allHabits);
    final children = _bundleService.getChildHabits(widget.habit, widget.allHabits);
    final progressPercentage = _bundleService.getBundleProgressPercentage(widget.habit, widget.allHabits);

    print('SmartBundle: ${widget.habit.name}, progress: ${progress.completed}/${progress.total}, children: ${children.length}'); // Debug

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isCompleted 
              ? Colors.green.withOpacity(0.1)
              : Theme.of(context).primaryColor.withOpacity(0.05),
            isCompleted 
              ? Colors.green.withOpacity(0.05)
              : Theme.of(context).primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCompleted 
            ? Colors.green.withOpacity(0.3)
            : Theme.of(context).primaryColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            _buildBundleHeader(context, progress, isCompleted, progressPercentage),
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _expandAnimation.value,
                    child: child,
                  ),
                );
              },
              child: _buildChildrenSection(children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleHeader(BuildContext context, BundleProgress progress, bool isCompleted, double progressPercentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isCompleted 
              ? Colors.green.withOpacity(0.15)
              : Theme.of(context).primaryColor.withOpacity(0.1),
            isCompleted 
              ? Colors.green.withOpacity(0.08)
              : Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Progress Ring
          _buildProgressRing(progress, isCompleted, progressPercentage, context),
          const SizedBox(width: 16),
          // Bundle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_special,
                      color: isCompleted ? Colors.green : Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.habit.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.green : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _bundleService.getBundleStatus(widget.habit, widget.allHabits),
                  style: TextStyle(
                    color: isCompleted ? Colors.green.shade700 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (widget.habit.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.habit.description,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Action Buttons
          _buildActionButtons(isCompleted),
        ],
      ),
    );
  }

  Widget _buildProgressRing(BundleProgress progress, bool isCompleted, double progressPercentage, BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(
              isCompleted ? Colors.green : Theme.of(context).primaryColor,
            ),
            strokeWidth: 5,
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${progress.completed}/${progress.total}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isCompleted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isCompleted)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _completeBundle(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Complete All', style: TextStyle(fontSize: 12)),
            ),
          ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _showAddHabitDialog,
          icon: Icon(
            Icons.add_circle_outline,
            color: Theme.of(context).primaryColor,
          ),
          tooltip: 'Add Habit to Bundle',
        ),
        IconButton(
          icon: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: _toggleExpansion,
          tooltip: _isExpanded ? 'Collapse' : 'Show Details',
        ),
      ],
    );
  }

  Widget _buildChildrenSection(List<Habit> children) {
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No habits in this bundle yet',
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Nested Habits (${children.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...children.map((child) => Container(
            margin: const EdgeInsets.only(bottom: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: HabitListTile(
              habit: child,
              isNested: true,
            ),
          )),
        ],
      ),
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _completeBundle() {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.completeBundle(widget.habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddHabitDialog() {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final availableHabits = habitsNotifier.getAvailableHabitsForBundle();
    
    if (availableHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available habits to add. Create some individual habits first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_circle, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text('Add to ${widget.habit.name}')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a habit to add to this bundle:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableHabits.length,
                  itemBuilder: (context, index) {
                    final habit = availableHabits[index];
                    return Card(
                      child: ListTile(
                        leading: _getHabitIcon(habit),
                        title: Text(habit.displayName),
                        subtitle: Text(habit.description),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).pop();
                          _addHabitToBundle(habit.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _getHabitIcon(Habit habit) {
    switch (habit.type) {
      case HabitType.basic:
        return const Icon(Icons.check_circle_outline, color: Colors.blue);
      case HabitType.avoidance:
        return const Icon(Icons.block, color: Colors.red);
      case HabitType.timedSession:
        return const Icon(Icons.timer, color: Colors.orange);
      case HabitType.timeWindow:
      case HabitType.dailyTimeWindow:
        return const Icon(Icons.schedule, color: Colors.green);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  void _addHabitToBundle(String habitId) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.addHabitToBundle(widget.habit.id, habitId);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Legacy bundle card (keeping for backward compatibility)
class BundleHabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final List<Habit> allHabits;

  const BundleHabitCard({super.key, required this.habit, required this.allHabits});

  @override
  ConsumerState<BundleHabitCard> createState() => _BundleHabitCardState();
}

class _BundleHabitCardState extends ConsumerState<BundleHabitCard> {
  bool _isExpanded = false;
  final _bundleService = BundleService();

  @override
  Widget build(BuildContext context) {
    final progress = _bundleService.getBundleProgress(widget.habit, widget.allHabits);
    final isCompleted = _bundleService.isBundleCompleted(widget.habit, widget.allHabits);
    final children = _bundleService.getChildHabits(widget.habit, widget.allHabits);
    final progressPercentage = _bundleService.getBundleProgressPercentage(widget.habit, widget.allHabits);

    print('Bundle card: ${widget.habit.name}, progress: ${progress.completed}/${progress.total}, children: ${children.length}'); // Debug

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                // Progress Ring
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          isCompleted ? Colors.green : Theme.of(context).primaryColor,
                        ),
                        strokeWidth: 4,
                      ),
                      Text(
                        '${progress.completed}/${progress.total}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Bundle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.folder, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.habit.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bundleService.getBundleStatus(widget.habit, widget.allHabits),
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isCompleted)
                      ElevatedButton.icon(
                        onPressed: () => _completeBundle(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: const Text('Complete All'),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _showAddHabitDialog,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add Habit to Bundle',
                    ),
                    IconButton(
                      icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Individual Habits:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...children.map((child) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: HabitListTile(habit: child),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _completeBundle() {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.completeBundle(widget.habit.id);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddHabitDialog() {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final availableHabits = habitsNotifier.getAvailableHabitsForBundle();
    
    if (availableHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available habits to add. Create some individual habits first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_circle, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text('Add to ${widget.habit.name}')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a habit to add to this bundle:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableHabits.length,
                  itemBuilder: (context, index) {
                    final habit = availableHabits[index];
                    return Card(
                      child: ListTile(
                        leading: _getHabitIcon(habit),
                        title: Text(habit.displayName),
                        subtitle: Text(habit.description),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).pop();
                          _addHabitToBundle(habit.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _getHabitIcon(Habit habit) {
    switch (habit.type) {
      case HabitType.basic:
        return const Icon(Icons.check_circle_outline, color: Colors.blue);
      case HabitType.avoidance:
        return const Icon(Icons.block, color: Colors.red);
      case HabitType.timedSession:
        return const Icon(Icons.timer, color: Colors.orange);
      case HabitType.timeWindow:
      case HabitType.dailyTimeWindow:
        return const Icon(Icons.schedule, color: Colors.green);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  void _addHabitToBundle(String habitId) {
    final habitsNotifier = ref.read(habitsProvider.notifier);
    final result = habitsNotifier.addHabitToBundle(widget.habit.id, habitId);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}