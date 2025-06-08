import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import 'package:data_local/repositories/habit_relationship_service.dart';

/// Reusable widget for selecting habits to add to groups
/// Supports different selection modes and validation
class HabitSelector extends StatefulWidget {
  final List<Habit> availableHabits;
  final List<String> selectedHabitIds;
  final Function(List<String>) onSelectionChanged;
  final HabitType groupType;
  final String? title;
  final String? subtitle;
  final int? maxSelections;
  final int? minSelections;
  final bool allowMultipleSelection;
  final double? height;

  const HabitSelector({
    super.key,
    required this.availableHabits,
    required this.selectedHabitIds,
    required this.onSelectionChanged,
    required this.groupType,
    this.title,
    this.subtitle,
    this.maxSelections,
    this.minSelections,
    this.allowMultipleSelection = true,
    this.height = 200,
  });

  @override
  State<HabitSelector> createState() => _HabitSelectorState();
}

class _HabitSelectorState extends State<HabitSelector> {
  final _relationshipService = HabitRelationshipService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
        ],
        if (widget.subtitle != null) ...[
          Text(
            widget.subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
        ],
        _buildHabitList(),
        const SizedBox(height: 8),
        _buildSelectionSummary(),
      ],
    );
  }

  Widget _buildHabitList() {
    if (widget.availableHabits.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.availableHabits.map((habit) => _buildHabitTile(habit)).toList(),
        ),
      ),
    );
  }

  Widget _buildHabitTile(Habit habit) {
    final isSelected = widget.selectedHabitIds.contains(habit.id);
    final canSelect = _canSelectHabit(habit);

    if (widget.allowMultipleSelection) {
      return CheckboxListTile(
        title: Text(
          habit.displayName,
          style: TextStyle(
            color: canSelect ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          habit.description,
          style: TextStyle(
            color: canSelect ? Colors.grey[600] : Colors.grey[400],
            fontSize: 12,
          ),
        ),
        value: isSelected,
        onChanged: canSelect ? (bool? selected) => _handleSelection(habit.id, selected) : null,
        dense: true,
        secondary: _getHabitTypeIcon(habit),
      );
    } else {
      return RadioListTile<String>(
        title: Text(
          habit.displayName,
          style: TextStyle(
            color: canSelect ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          habit.description,
          style: TextStyle(
            color: canSelect ? Colors.grey[600] : Colors.grey[400],
            fontSize: 12,
          ),
        ),
        value: habit.id,
        groupValue: widget.selectedHabitIds.isNotEmpty ? widget.selectedHabitIds.first : null,
        onChanged: canSelect ? (String? value) => _handleSingleSelection(value) : null,
        dense: true,
        secondary: _getHabitTypeIcon(habit),
      );
    }
  }

  Widget _buildEmptyState() {
    String message;
    switch (widget.groupType) {
      case HabitType.bundle:
        message = 'No available habits to bundle.\nCreate some individual habits first.';
        break;
      case HabitType.stack:
        message = 'No available habits to stack on.\nCreate some basic habits first.';
        break;
      default:
        message = 'No available habits found.';
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 32, color: Colors.orange.shade700),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    if (widget.selectedHabitIds.isEmpty) return const SizedBox.shrink();

    final validationResult = _relationshipService.validateGrouping(
      childIds: widget.selectedHabitIds,
      groupType: widget.groupType,
      allHabits: widget.availableHabits,
    );

    final count = widget.selectedHabitIds.length;
    final isValid = validationResult.isValid;
    final color = isValid ? Colors.green.shade700 : Colors.orange.shade700;
    final backgroundColor = isValid ? Colors.green.shade50 : Colors.orange.shade50;

    String message = '$count habit${count == 1 ? '' : 's'} selected';
    if (!isValid && validationResult.errorMessage != null) {
      message += ' (${validationResult.errorMessage})';
    } else if (isValid) {
      message += ' ✓';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.warning_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSelectHabit(Habit habit) {
    // Check max selections
    if (widget.maxSelections != null && 
        widget.selectedHabitIds.length >= widget.maxSelections! &&
        !widget.selectedHabitIds.contains(habit.id)) {
      return false;
    }

    // Type-specific validation
    switch (widget.groupType) {
      case HabitType.bundle:
        return habit.type != HabitType.bundle;
      case HabitType.stack:
        return habit.type != HabitType.stack;
      default:
        return true;
    }
  }

  void _handleSelection(String habitId, bool? selected) {
    final newSelection = List<String>.from(widget.selectedHabitIds);
    
    if (selected == true) {
      if (!newSelection.contains(habitId)) {
        newSelection.add(habitId);
      }
    } else {
      newSelection.remove(habitId);
    }
    
    widget.onSelectionChanged(newSelection);
  }

  void _handleSingleSelection(String? habitId) {
    if (habitId != null) {
      widget.onSelectionChanged([habitId]);
    } else {
      widget.onSelectionChanged([]);
    }
  }

  Widget _getHabitTypeIcon(Habit habit) {
    switch (habit.type) {
      case HabitType.basic:
        return Icon(Icons.check_circle_outline, color: Colors.blue, size: 20);
      case HabitType.avoidance:
        return Icon(Icons.block, color: Colors.red, size: 20);
      // TODO(bridger): Disabled time-based habit types
      // case HabitType.timedSession:
      //   return Icon(Icons.timer, color: Colors.orange, size: 20);
      // case HabitType.timeWindow:
      // case HabitType.dailyTimeWindow:
      //   return Icon(Icons.schedule, color: Colors.green, size: 20);
      // case HabitType.alarmHabit:
      //   return Icon(Icons.alarm, color: Colors.purple, size: 20);
      case HabitType.stack:
        return Icon(Icons.layers, color: Colors.indigo, size: 20);
      case HabitType.bundle:
        return Icon(Icons.folder, color: Colors.brown, size: 20);
      default:
        return Icon(Icons.circle, color: Colors.grey, size: 20);
    }
  }
}

/// Validation result for habit selection
class HabitSelectionValidation {
  final bool isValid;
  final String? message;
  final List<String> validHabitIds;

  const HabitSelectionValidation({
    required this.isValid,
    this.message,
    required this.validHabitIds,
  });

  factory HabitSelectionValidation.valid(List<String> habitIds) {
    return HabitSelectionValidation(
      isValid: true,
      validHabitIds: habitIds,
    );
  }

  factory HabitSelectionValidation.invalid(String message, List<String> habitIds) {
    return HabitSelectionValidation(
      isValid: false,
      message: message,
      validHabitIds: habitIds,
    );
  }
}