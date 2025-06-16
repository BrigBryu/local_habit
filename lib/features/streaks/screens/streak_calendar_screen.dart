import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/flexible_theme_system.dart';
import '../widgets/day_detail_bottom_sheet.dart';

enum CalendarView { calendar, stats }

final selectedHabitFilterProvider = StateProvider<String>((ref) => 'All Habits');
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final calendarViewProvider = StateProvider<CalendarView>((ref) => CalendarView.calendar);

class StreakCalendarScreen extends ConsumerWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final selectedView = ref.watch(calendarViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Streak Calendar',
          style: TextStyle(
            color: colors.draculaForeground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.draculaBackground,
        foregroundColor: colors.draculaForeground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: colors.draculaForeground),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // Large segmented control for view switch
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.draculaCurrentLine.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildViewToggle(
                        context,
                        ref,
                        'Calendar',
                        CalendarView.calendar,
                        Icons.calendar_month,
                        selectedView == CalendarView.calendar,
                      ),
                    ),
                    Expanded(
                      child: _buildViewToggle(
                        context,
                        ref,
                        'Stats',
                        CalendarView.stats,
                        Icons.bar_chart,
                        selectedView == CalendarView.stats,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Filter row
              _buildFilterRow(context, ref),
            ],
          ),
        ),
      ),
      backgroundColor: colors.draculaBackground,
      body: selectedView == CalendarView.calendar
          ? _buildCalendarView(context, ref)
          : _buildStatsView(context, ref),
    );
  }

  Widget _buildViewToggle(
    BuildContext context,
    WidgetRef ref,
    String label,
    CalendarView view,
    IconData icon,
    bool isSelected,
  ) {
    final colors = ref.watchColors;

    return GestureDetector(
      onTap: () => ref.read(calendarViewProvider.notifier).state = view,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? colors.primaryPurple.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? colors.primaryPurple.withOpacity(0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? colors.primaryPurple : colors.draculaComment,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.primaryPurple : colors.draculaComment,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final selectedFilter = ref.watch(selectedHabitFilterProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Habit filter dropdown
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.draculaCurrentLine.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.draculaCurrentLine,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  isDense: true,
                  dropdownColor: colors.draculaCurrentLine,
                  style: TextStyle(
                    color: colors.draculaForeground,
                    fontSize: 14,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: colors.draculaComment,
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(selectedHabitFilterProvider.notifier).state = value;
                    }
                  },
                  items: _getHabitFilterOptions().map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(color: colors.draculaForeground),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Month navigation
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final newMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
                    ref.read(selectedMonthProvider.notifier).state = newMonth;
                  },
                  icon: Icon(Icons.chevron_left, color: colors.draculaForeground),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                
                Text(
                  _formatMonth(selectedMonth),
                  style: TextStyle(
                    color: colors.draculaForeground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                IconButton(
                  onPressed: () {
                    final newMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
                    ref.read(selectedMonthProvider.notifier).state = newMonth;
                  },
                  icon: Icon(Icons.chevron_right, color: colors.draculaForeground),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedFilter = ref.watch(selectedHabitFilterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar widget
          Container(
            decoration: BoxDecoration(
              color: colors.draculaCurrentLine.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.draculaCurrentLine,
                width: 1,
              ),
            ),
            child: TableCalendar<dynamic>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedMonth,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              
              // Styling
              calendarStyle: CalendarStyle(
                // Outside days (previous/next month)
                outsideDaysVisible: false,
                
                // Weekend styling
                weekendTextStyle: TextStyle(color: colors.draculaForeground),
                
                // Default day styling
                defaultTextStyle: TextStyle(color: colors.draculaForeground),
                
                // Today styling
                todayTextStyle: TextStyle(
                  color: colors.draculaBackground,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: colors.primaryPurple,
                  shape: BoxShape.circle,
                ),
                
                // Selected day styling
                selectedTextStyle: TextStyle(
                  color: colors.draculaBackground,
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: BoxDecoration(
                  color: colors.purpleAccent,
                  shape: BoxShape.circle,
                ),
                
                // Marker styling
                markerDecoration: BoxDecoration(
                  color: colors.draculaCyan,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                
                // Cell styling
                cellMargin: const EdgeInsets.all(4),
                cellPadding: EdgeInsets.zero,
              ),
              
              // Header styling
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronVisible: false,
                rightChevronVisible: false,
                titleTextStyle: TextStyle(
                  color: colors.draculaForeground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Days of week styling
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: colors.draculaComment,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: TextStyle(
                  color: colors.draculaComment,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              // Calendar builders
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildCalendarDay(context, ref, day, selectedFilter);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildCalendarDay(context, ref, day, selectedFilter, isToday: true);
                },
              ),
              
              // Event handling
              onDaySelected: (selectedDay, focusedDay) {
                showDayDetailBottomSheet(
                  context,
                  date: selectedDay,
                  habitFilter: selectedFilter != 'All Habits' ? selectedFilter : null,
                );
              },
              
              onPageChanged: (focusedDay) {
                ref.read(selectedMonthProvider.notifier).state = focusedDay;
              },
            ),
          ),

          const SizedBox(height: 24),

          // Legend
          _buildLegend(context, ref),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    String selectedFilter, {
    bool isToday = false,
  }) {
    final colors = ref.watchColors;
    final myCompleted = _isMyHabitCompletedOnDate(day, selectedFilter);
    final partnerCompleted = _isPartnerHabitCompletedOnDate(day, selectedFilter);
    final habitCount = _getHabitCountForDate(day, selectedFilter);

    Color backgroundColor;
    List<Color> gradientColors;
    Color borderColor;

    if (myCompleted && partnerCompleted) {
      // Both completed - solid gradient
      gradientColors = [
        colors.primaryPurple.withOpacity(0.8),
        colors.purpleAccent.withOpacity(0.8),
      ];
      backgroundColor = colors.primaryPurple.withOpacity(0.3);
      borderColor = colors.primaryPurple;
    } else if (myCompleted || partnerCompleted) {
      // Only one completed - 50% opacity
      final completedColor = myCompleted ? colors.primaryPurple : colors.purpleAccent;
      gradientColors = [
        completedColor.withOpacity(0.5),
        completedColor.withOpacity(0.3),
      ];
      backgroundColor = completedColor.withOpacity(0.1);
      borderColor = completedColor.withOpacity(0.6);
    } else {
      // Break - outline only
      gradientColors = [Colors.transparent, Colors.transparent];
      backgroundColor = Colors.transparent;
      borderColor = colors.draculaCurrentLine;
    }

    return GestureDetector(
      onTap: () => showDayDetailBottomSheet(
        context,
        date: day,
        habitFilter: selectedFilter != 'All Habits' ? selectedFilter : null,
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isToday ? colors.draculaYellow : borderColor,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Day number
            Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isToday
                      ? colors.draculaYellow
                      : (myCompleted || partnerCompleted)
                          ? colors.draculaBackground
                          : colors.draculaForeground,
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),

            // Small stacked avatars (bottom-right)
            if (myCompleted || partnerCompleted)
              Positioned(
                bottom: 2,
                right: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (myCompleted)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primaryPurple,
                          border: Border.all(
                            color: colors.draculaBackground,
                            width: 0.5,
                          ),
                        ),
                      ),
                    if (partnerCompleted)
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(left: myCompleted ? 1 : 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.purpleAccent,
                          border: Border.all(
                            color: colors.draculaBackground,
                            width: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Habit count badge (top-right)
            if (habitCount > 0)
              Positioned(
                top: 1,
                right: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.draculaCyan,
                  ),
                  child: Center(
                    child: Text(
                      '$habitCount',
                      style: TextStyle(
                        color: colors.draculaBackground,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.draculaCurrentLine.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.draculaCurrentLine,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: TextStyle(
              color: colors.draculaForeground,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  context,
                  ref,
                  'Both completed',
                  [colors.primaryPurple, colors.purpleAccent],
                  isSolid: true,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  context,
                  ref,
                  'One completed',
                  [colors.primaryPurple.withOpacity(0.5)],
                  isSolid: false,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  context,
                  ref,
                  'Streak break',
                  [Colors.transparent],
                  borderColor: colors.draculaCurrentLine,
                  isSolid: false,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  context,
                  ref,
                  'Today',
                  [Colors.transparent],
                  borderColor: colors.draculaYellow,
                  isSolid: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    WidgetRef ref,
    String label,
    List<Color> colors, {
    Color? borderColor,
    bool isSolid = false,
  }) {
    final themeColors = ref.watchColors;

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            gradient: colors.length > 1
                ? LinearGradient(colors: colors)
                : null,
            color: colors.length == 1 ? colors.first : null,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor ?? (isSolid ? Colors.transparent : themeColors.draculaCurrentLine),
              width: borderColor != null ? 2 : 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: themeColors.draculaForeground,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsView(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats cards
          _buildStatsCard(
            context,
            ref,
            'Current Streak',
            '23 days',
            colors.primaryPurple,
            Icons.local_fire_department,
          ),
          
          const SizedBox(height: 16),
          
          _buildStatsCard(
            context,
            ref,
            'Best Streak',
            '45 days',
            colors.draculaYellow,
            Icons.emoji_events,
          ),
          
          const SizedBox(height: 16),
          
          _buildStatsCard(
            context,
            ref,
            'Completion Rate',
            '85%',
            colors.draculaGreen,
            Icons.trending_up,
          ),
          
          const SizedBox(height: 24),
          
          // Coming soon placeholder
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colors.draculaCurrentLine.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.draculaCurrentLine,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: colors.draculaComment,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'More Stats Coming Soon',
                  style: TextStyle(
                    color: colors.draculaComment,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Detailed analytics and insights will be available here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.draculaComment,
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

  Widget _buildStatsCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    final colors = ref.watchColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.draculaCurrentLine.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.draculaComment,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getHabitFilterOptions() {
    // Mock data - replace with actual habit data
    return [
      'All Habits',
      'Morning Exercise',
      'Read Book',
      'Drink Water',
      'Meditation',
      'No Social Media',
    ];
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isMyHabitCompletedOnDate(DateTime date, String filter) {
    // Mock logic - replace with actual data
    if (filter == 'All Habits') {
      return date.day % 2 == 0;
    }
    return date.day % 3 == 0;
  }

  bool _isPartnerHabitCompletedOnDate(DateTime date, String filter) {
    // Mock logic - replace with actual data
    if (filter == 'All Habits') {
      return date.day % 3 == 0;
    }
    return date.day % 4 == 0;
  }

  int _getHabitCountForDate(DateTime date, String filter) {
    // Mock logic - replace with actual data
    if (filter == 'All Habits') {
      return 3 + (date.day % 3);
    }
    return 1;
  }
}