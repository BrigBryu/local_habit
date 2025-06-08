import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:domain/domain.dart' hide TimeOfDay;
import 'core/extensions/time_of_day_extensions.dart';
import 'core/extensions/habit_icon_extensions.dart';

void main() {
  runApp(const HabitLevelUpApp());
}

class HabitLevelUpApp extends StatelessWidget {
  const HabitLevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Level Up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HabitsTablePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HabitsTablePage extends StatefulWidget {
  const HabitsTablePage({super.key});

  @override
  State<HabitsTablePage> createState() => _HabitsTablePageState();
}

class _HabitsTablePageState extends State<HabitsTablePage> {
  final HabitUseCases _habitService = HabitUseCases();
  final TimeService _timeService = TimeService();
  final LevelService _levelService = LevelService();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = _habitService.getVisibleHabits();
    final level = _levelService.currentLevel;
    final xp = _levelService.currentXP;
    final nextLevelXP = _levelService.xpForNextLevel;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Habit Level Up'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showKeyboardHelp,
              tooltip: 'Keyboard Commands',
            ),
          ],
        ),
        body: Column(
          children: [
            // Level progress bar
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Level $level',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$xp / $nextLevelXP XP',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: xp / nextLevelXP,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Time info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    _habitService.getCurrentDateInfo(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Habits section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Table header
                    const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Habit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Streak',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Action',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    
                    // Habits list or empty state
                    Expanded(
                      child: habits.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No habits yet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Press "Add New Habit" below to get started\nOr press "H" for keyboard commands',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: habits.length,
                              itemBuilder: (context, index) {
                                final habit = habits[index];
                                return _buildHabitCard(habit);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Add habit button
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _showAddHabitDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add New Habit'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(BaseHabit habit) {
    final isCompleted = _habitService.isCompletedToday(habit.id);
    final displayName = _habitService.getHabitDisplayName(habit.id);
    final canComplete = habit.canComplete(_timeService);
    final statusText = habit.getStatusText(_timeService);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Habit info
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        habit.icon.toIconData(),
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (habit.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      habit.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    habit.typeName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Status
            Expanded(
              flex: 2,
              child: Text(
                statusText,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Streak
            Expanded(
              flex: 1,
              child: Text(
                habit.currentStreak > 0 ? '🔥 ${habit.currentStreak}' : '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Action button
            Expanded(
              flex: 1,
              child: _buildActionButton(habit, canComplete, isCompleted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BaseHabit habit, bool canComplete, bool isCompleted) {
    if (habit is TimedSessionHabit) {
      if (habit.sessionStartTime == null && habit.canStartSession(_timeService)) {
        return IconButton(
          onPressed: () => _startTimedSession(habit.id),
          icon: const Icon(Icons.play_arrow),
          color: Colors.green,
          tooltip: 'Start Session',
        );
      } else if (canComplete && !isCompleted) {
        return IconButton(
          onPressed: () => _completeHabit(habit.id),
          icon: const Icon(Icons.check_circle),
          color: Colors.green,
          tooltip: 'Complete',
        );
      }
    }
    
    if (canComplete && !isCompleted) {
      return IconButton(
        onPressed: () => _completeHabit(habit.id),
        icon: const Icon(Icons.check_circle_outline),
        color: Colors.green,
        tooltip: 'Complete',
      );
    }
    
    return IconButton(
      onPressed: null,
      icon: Icon(
        isCompleted ? Icons.check_circle : Icons.check_circle_outline,
        color: isCompleted ? Colors.green : Colors.grey,
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey.keyLabel.toUpperCase()) {
        case 'N':
          _advanceDay();
          break;
        case 'R':
          _resetTime();
          break;
        case 'C':
          _clearAndReset();
          break;
        case 'D':
          _showDebugInfo();
          break;
        case 'H':
          _showKeyboardHelp();
          break;
      }
    }
  }

  void _advanceDay() {
    _timeService.nextDay();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Advanced to ${_habitService.getCurrentDateInfo()}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _resetTime() {
    _timeService.resetToRealTime();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to real time'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearAndReset() {
    _habitService.resetAllHabits();
    _levelService.reset();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All habits cleared and level reset!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showDebugInfo() {
    final habits = _habitService.getAllHabits();
    final debugInfo = StringBuffer();
    debugInfo.writeln('=== DEBUG INFO ===');
    debugInfo.writeln(_habitService.getCurrentDateInfo());
    debugInfo.writeln('Level: ${_levelService.currentLevel}');
    debugInfo.writeln('XP: ${_levelService.currentXP}');
    debugInfo.writeln('');
    
    for (final habit in habits) {
      final stats = _habitService.getHabitStats(habit.id);
      debugInfo.writeln('${stats['name']} (${stats['type']}):');
      debugInfo.writeln('  Streak: ${stats['currentStreak']}');
      debugInfo.writeln('  Completed today: ${stats['completedToday']}');
      debugInfo.writeln('  Can complete: ${stats['canComplete']}');
      debugInfo.writeln('  Status: ${stats['statusText']}');
      debugInfo.writeln('');
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Text(
            debugInfo.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showKeyboardHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Commands'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Testing Commands:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('N - Next Day (advance simulation by 1 day)'),
              Text('R - Reset Time (back to real-time)'),
              Text('C - Clear & Reset (clear all habits and reset level)'),
              Text('D - Debug Info (show detailed statistics)'),
              Text('H - Help (show this dialog)'),
              SizedBox(height: 16),
              Text('Habit Types Available:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Basic Habit - Standard daily habit'),
              Text('• Habit Stack - Unlocks after base habit completed'),
              Text('• Alarm Habit - Time-based with completion window'),
              Text('• Timed Session - Click-to-start timer with grace period'),
              Text('• Time Window - Only available during specific hours/days'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddHabitDialog() async {
    HabitType selectedType = HabitType.basic;
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedBaseHabitId;
    TimeOfDay? alarmTime;
    int windowMinutes = 30;
    int sessionMinutes = 25;
    int graceMinutes = 15;
    TimeOfDay? windowStartTime;
    TimeOfDay? windowEndTime;
    List<int> availableDays = [1, 2, 3, 4, 5]; // Weekdays by default

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Habit type selector
                DropdownButtonFormField<HabitType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Habit Type',
                    border: OutlineInputBorder(),
                  ),
                  items: HabitType.values.map((type) {
                    final baseHabits = _habitService.getBaseHabits();
                    final canCreateStack = type != HabitType.stack || baseHabits.isNotEmpty;
                    
                    return DropdownMenuItem<HabitType>(
                      value: type,
                      enabled: canCreateStack,
                      child: Text(
                        type.displayName,
                        style: TextStyle(
                          color: canCreateStack ? null : Colors.grey,
                          decoration: canCreateStack ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (HabitType? newType) {
                    if (newType != null) {
                      setDialogState(() {
                        selectedType = newType;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Name field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    hintText: 'e.g., Drink 8 glasses of water',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                
                // Description field
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Why is this habit important?',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Type-specific fields
                ...(_buildTypeSpecificFields(
                  selectedType,
                  setDialogState,
                  selectedBaseHabitId,
                  alarmTime,
                  windowMinutes,
                  sessionMinutes,
                  graceMinutes,
                  windowStartTime,
                  windowEndTime,
                  availableDays,
                  (value) => selectedBaseHabitId = value,
                  (value) => alarmTime = value,
                  (value) => windowMinutes = value,
                  (value) => sessionMinutes = value,
                  (value) => graceMinutes = value,
                  (value) => windowStartTime = value,
                  (value) => windowEndTime = value,
                  (value) => availableDays = value,
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _createHabit(
                context,
                selectedType,
                nameController.text,
                descriptionController.text,
                selectedBaseHabitId,
                alarmTime,
                windowMinutes,
                sessionMinutes,
                graceMinutes,
                windowStartTime,
                windowEndTime,
                availableDays,
              ),
              child: const Text('Add Habit'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTypeSpecificFields(
    HabitType type,
    StateSetter setDialogState,
    String? selectedBaseHabitId,
    TimeOfDay? alarmTime,
    int windowMinutes,
    int sessionMinutes,
    int graceMinutes,
    TimeOfDay? windowStartTime,
    TimeOfDay? windowEndTime,
    List<int> availableDays,
    Function(String?) setBaseHabitId,
    Function(TimeOfDay?) setAlarmTime,
    Function(int) setWindowMinutes,
    Function(int) setSessionMinutes,
    Function(int) setGraceMinutes,
    Function(TimeOfDay?) setWindowStartTime,
    Function(TimeOfDay?) setWindowEndTime,
    Function(List<int>) setAvailableDays,
  ) {
    switch (type) {
      case HabitType.stack:
      case HabitType.alarmHabit:
        final baseHabits = _habitService.getBaseHabits();
        return [
          DropdownButtonFormField<String>(
            value: selectedBaseHabitId,
            decoration: const InputDecoration(
              labelText: 'Base Habit',
              border: OutlineInputBorder(),
            ),
            items: baseHabits.map((habit) => DropdownMenuItem<String>(
              value: habit.id,
              child: Text(habit.name),
            )).toList(),
            onChanged: (value) {
              setDialogState(() {
                setBaseHabitId(value);
              });
            },
          ),
          const SizedBox(height: 16),
          if (type == HabitType.alarmHabit) ...[
            ListTile(
              title: const Text('Alarm Time'),
              subtitle: Text(alarmTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: alarmTime ?? const TimeOfDay(hour: 7, minute: 0),
                );
                if (time != null) {
                  setDialogState(() {
                    setAlarmTime(time);
                  });
                }
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Completion Window (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: windowMinutes.toString()),
              onChanged: (value) {
                final minutes = int.tryParse(value) ?? 30;
                setWindowMinutes(minutes);
              },
            ),
            const SizedBox(height: 16),
          ],
        ];

      case HabitType.timedSession:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Session Duration (minutes)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: sessionMinutes.toString()),
            onChanged: (value) {
              final minutes = int.tryParse(value) ?? 25;
              setSessionMinutes(minutes);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Grace Period (minutes)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: graceMinutes.toString()),
            onChanged: (value) {
              final minutes = int.tryParse(value) ?? 15;
              setGraceMinutes(minutes);
            },
          ),
          const SizedBox(height: 16),
        ];

      case HabitType.timeWindow:
        return [
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(windowStartTime?.format(context) ?? 'Not set'),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: windowStartTime ?? const TimeOfDay(hour: 9, minute: 0),
              );
              if (time != null) {
                setDialogState(() {
                  setWindowStartTime(time);
                });
              }
            },
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(windowEndTime?.format(context) ?? 'Not set'),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: windowEndTime ?? const TimeOfDay(hour: 17, minute: 0),
              );
              if (time != null) {
                setDialogState(() {
                  setWindowEndTime(time);
                });
              }
            },
          ),
          const Text('Available Days:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            children: [
              for (int i = 1; i <= 7; i++)
                FilterChip(
                  label: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1]),
                  selected: availableDays.contains(i),
                  onSelected: (selected) {
                    setDialogState(() {
                      if (selected) {
                        availableDays.add(i);
                      } else {
                        availableDays.remove(i);
                      }
                      setAvailableDays(List.from(availableDays));
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
        ];

      default:
        return [];
    }
  }

  Future<void> _createHabit(
    BuildContext context,
    HabitType type,
    String name,
    String description,
    String? selectedBaseHabitId,
    TimeOfDay? alarmTime,
    int windowMinutes,
    int sessionMinutes,
    int graceMinutes,
    TimeOfDay? windowStartTime,
    TimeOfDay? windowEndTime,
    List<int> availableDays,
  ) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    try {
      String habitId;
      
      switch (type) {
        case HabitType.basic:
          habitId = await _habitService.addBasicHabit(
            name: trimmedName,
            description: description.trim(),
          );
          break;
        
        case HabitType.stack:
          if (selectedBaseHabitId == null) return;
          habitId = await _habitService.addHabitStack(
            name: trimmedName,
            description: description.trim(),
            stackedOnHabitId: selectedBaseHabitId,
          );
          break;
        
        case HabitType.alarmHabit:
          if (selectedBaseHabitId == null || alarmTime == null) return;
          habitId = await _habitService.addAlarmHabit(
            name: trimmedName,
            description: description.trim(),
            stackedOnHabitId: selectedBaseHabitId,
            alarmTime: alarmTime.toDomain(),
            windowMinutes: windowMinutes,
          );
          break;
        
        case HabitType.timedSession:
          habitId = await _habitService.addTimedSessionHabit(
            name: trimmedName,
            description: description.trim(),
            sessionMinutes: sessionMinutes,
            graceMinutes: graceMinutes,
          );
          break;
        
        case HabitType.timeWindow:
          if (windowStartTime == null || windowEndTime == null || availableDays.isEmpty) return;
          habitId = await _habitService.addTimeWindowHabit(
            name: trimmedName,
            description: description.trim(),
            windowStartTime: windowStartTime.toDomain(),
            windowEndTime: windowEndTime.toDomain(),
            availableDays: availableDays,
          );
          break;
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${type.displayName}: $trimmedName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeHabit(String habitId) async {
    try {
      await _habitService.completeHabit(habitId);
      final habit = _habitService.getHabitById(habitId);
      final xpGained = habit?.getTotalXP() ?? 1;
      _levelService.addXP(xpGained);
      
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habit completed! +$xpGained XP 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _startTimedSession(String habitId) async {
    try {
      await _habitService.startTimedSession(habitId);
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session started! ⏱️'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}