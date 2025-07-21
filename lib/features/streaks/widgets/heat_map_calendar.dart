import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_controller.dart';

/// Heat map calendar widget showing habit completion patterns
class HeatMapCalendar extends ConsumerWidget {
  const HeatMapCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            colors.draculaCurrentLine.withOpacity(0.6),
            colors.draculaCurrentLine.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.draculaCurrentLine,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Heatmap',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.draculaForeground,
            ),
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(colors),
          const SizedBox(height: 12),
          _buildLegend(colors),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(colors) {
    // Generate 7 weeks of data (49 days)
    final weeks = <Widget>[];
    
    for (int week = 0; week < 7; week++) {
      final days = <Widget>[];
      
      for (int day = 0; day < 7; day++) {
        final intensity = _getMockIntensity(week, day);
        days.add(_buildDayCell(colors, intensity));
      }
      
      weeks.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days,
      ));
    }
    
    return Column(children: weeks);
  }

  Widget _buildDayCell(colors, double intensity) {
    Color cellColor;
    
    if (intensity == 0) {
      cellColor = colors.draculaCurrentLine;
    } else if (intensity <= 0.25) {
      cellColor = colors.draculaGreen.withOpacity(0.3);
    } else if (intensity <= 0.5) {
      cellColor = colors.draculaGreen.withOpacity(0.5);
    } else if (intensity <= 0.75) {
      cellColor = colors.draculaGreen.withOpacity(0.7);
    } else {
      cellColor = colors.draculaGreen;
    }
    
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: colors.draculaCurrentLine.withOpacity(0.3),
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildLegend(colors) {
    return Row(
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 12,
            color: colors.draculaComment,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            _buildLegendCell(colors.draculaCurrentLine),
            _buildLegendCell(colors.draculaGreen.withOpacity(0.3)),
            _buildLegendCell(colors.draculaGreen.withOpacity(0.5)),
            _buildLegendCell(colors.draculaGreen.withOpacity(0.7)),
            _buildLegendCell(colors.draculaGreen),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          'More',
          style: TextStyle(
            fontSize: 12,
            color: colors.draculaComment,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendCell(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  /// Mock intensity data for demonstration
  double _getMockIntensity(int week, int day) {
    // Create a pattern that shows varying activity levels
    final dayIndex = week * 7 + day;
    final patterns = [0.0, 0.2, 0.4, 0.8, 1.0, 0.6, 0.3];
    return patterns[dayIndex % patterns.length];
  }
}