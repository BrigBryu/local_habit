import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/flexible_theme_system.dart';
import '../../../providers/longest_streak_provider.dart';
import '../widgets/day_detail_bottom_sheet.dart';
import '../widgets/heat_map_calendar.dart';
import 'dart:ui' as ui;

class StreaksScreen extends ConsumerWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;

    return SafeArea(
      child: Column(
        children: [
          // Header with back button simulation removed since we're in bottom nav
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Streaks & Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.draculaForeground,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showStreakInfo(context),
                  icon: Icon(Icons.info_outline, color: colors.draculaCyan),
                  tooltip: 'Streak Info',
                ),
              ],
            ),
          ),
          // Body content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Longest Streak Meter
                  _buildLongestStreakMeter(ref),
                  
                  const SizedBox(height: 24),
                  
                  // Heat Map Calendar
                  const HeatMapCalendar(),
                  
                  const SizedBox(height: 24),
                  
                  // Analytics Card
                  _buildAnalyticsCard(ref),
                  
                  const SizedBox(height: 24),

                  // Streak Summary Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStreakSummaryCard(
                          context,
                          ref,
                          isMe: true,
                          streakDays: 23,
                          startDate:
                              DateTime.now().subtract(const Duration(days: 22)),
                          endDate: DateTime.now(),
                          completionRate: 0.85,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStreakSummaryCard(
                          context,
                          ref,
                          isMe: false,
                          streakDays: 18,
                          startDate:
                              DateTime.now().subtract(const Duration(days: 17)),
                          endDate: DateTime.now(),
                          completionRate: 0.78,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    color: colors.draculaCurrentLine,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),

                  const SizedBox(height: 24),

                  // Day Tiles Section
                  _buildDayTilesSection(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSummaryCard(
    BuildContext context,
    WidgetRef ref, {
    required bool isMe,
    required int streakDays,
    required DateTime startDate,
    required DateTime endDate,
    required double completionRate,
  }) {
    final colors = ref.watchColors;
    final primaryColor = isMe ? colors.primaryPurple : colors.purpleAccent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: colors.draculaCurrentLine.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and title row
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.15),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isMe ? 'M' : 'P',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isMe ? 'My Streak' : 'Partner\'s Streak',
                          style: TextStyle(
                            color: colors.draculaForeground,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Streak count
                  Text(
                    '$streakDays-DAY STREAK',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Date range
                  Text(
                    'since ${_formatDate(startDate)} – through ${_formatDate(endDate)}',
                    style: TextStyle(
                      color: colors.draculaComment,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress ring
                  Row(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          children: [
                            // Background circle
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    colors.draculaCurrentLine.withOpacity(0.3),
                              ),
                            ),
                            // Progress circle
                            CircularProgressIndicator(
                              value: completionRate,
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                              backgroundColor:
                                  colors.draculaCurrentLine.withOpacity(0.2),
                            ),
                            // Center percentage
                            Center(
                              child: Text(
                                '${(completionRate * 100).round()}%',
                                style: TextStyle(
                                  color: colors.draculaForeground,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Last 30 days completion',
                          style: TextStyle(
                            color: colors.draculaComment,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildDayTilesSection(BuildContext context, WidgetRef ref) {
    final colors = ref.watchColors;
    final last30Days = List.generate(
        30, (index) => DateTime.now().subtract(Duration(days: 29 - index)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: colors.primaryPurple,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Last 30 Days',
              style: TextStyle(
                color: colors.draculaForeground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Day tiles list
        ...last30Days.map((date) => _buildDayTile(context, ref, date)),
      ],
    );
  }

  Widget _buildDayTile(BuildContext context, WidgetRef ref, DateTime date) {
    final colors = ref.watchColors;
    final isToday = _isToday(date);
    final myCompleted = _isMyHabitCompletedOnDate(date);
    final partnerCompleted = _isPartnerHabitCompletedOnDate(date);
    final habitCount = _getHabitCountForDate(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isToday
            ? colors.primaryPurple.withOpacity(0.1)
            : colors.draculaCurrentLine.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? colors.primaryPurple.withOpacity(0.3)
              : colors.draculaCurrentLine,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showDayDetailBottomSheet(context, date: date),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Day label
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDayLabel(date),
                      style: TextStyle(
                        color: isToday
                            ? colors.primaryPurple
                            : colors.draculaForeground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Today',
                        style: TextStyle(
                          color: colors.primaryPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Check icons
              Row(
                children: [
                  // My completion
                  Icon(
                    myCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: myCompleted
                        ? colors.primaryPurple
                        : colors.draculaComment,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  // Partner completion
                  Icon(
                    partnerCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: partnerCompleted
                        ? colors.purpleAccent
                        : colors.draculaComment,
                    size: 24,
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Habit count chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.draculaCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.draculaCyan.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$habitCount habits',
                  style: TextStyle(
                    color: colors.draculaCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: colors.draculaComment,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month = months[date.month - 1];
    return '$month ${date.day}';
  }

  String _formatDayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final dayName = days[date.weekday - 1];
    final month = months[date.month - 1];

    return '$dayName • $month ${date.day}';
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isMyHabitCompletedOnDate(DateTime date) {
    // Mock logic - replace with actual data
    return date.day % 2 == 0;
  }

  bool _isPartnerHabitCompletedOnDate(DateTime date) {
    // Mock logic - replace with actual data
    return date.day % 3 == 0;
  }

  int _getHabitCountForDate(DateTime date) {
    // Mock logic - replace with actual data
    return 3 + (date.day % 3);
  }

  Widget _buildLongestStreakMeter(WidgetRef ref) {
    final colors = ref.watchColors;
    final longestStreakAsync = ref.watch(longestStreakProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            colors.draculaPink.withOpacity(0.2),
            colors.draculaPurple.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.draculaPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            color: colors.draculaPink,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Longest Streak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.draculaForeground,
                  ),
                ),
                const SizedBox(height: 4),
                longestStreakAsync.when(
                  data: (streak) => Text(
                    '$streak days',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.draculaPink,
                    ),
                  ),
                  loading: () => Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.draculaComment,
                    ),
                  ),
                  error: (_, __) => Text(
                    '0 days',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.draculaComment,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(WidgetRef ref) {
    final colors = ref.watchColors;
    // Mock check for analytics purchase - in real app, check user's purchases
    final hasAnalytics = false; // Placeholder
    
    return GestureDetector(
      onTap: hasAnalytics ? null : () => _navigateToShopUtilities(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: hasAnalytics 
              ? colors.draculaCurrentLine.withOpacity(0.6)
              : colors.draculaCurrentLine.withOpacity(0.3),
          border: Border.all(
            color: hasAnalytics 
                ? colors.draculaCyan.withOpacity(0.5)
                : colors.draculaComment.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.analytics,
              color: hasAnalytics ? colors.draculaCyan : colors.draculaComment,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Analytics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasAnalytics 
                          ? colors.draculaForeground 
                          : colors.draculaComment,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasAnalytics 
                        ? 'View detailed insights'
                        : 'Purchase to unlock analytics',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.draculaComment,
                    ),
                  ),
                ],
              ),
            ),
            if (!hasAnalytics)
              Icon(
                Icons.lock,
                color: colors.draculaComment,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToShopUtilities() {
    // Navigate to shop utilities tab
    // This would be implemented based on the app's navigation structure
  }

  void _showStreakInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Streak Information'),
        content: const Text(
          'Streaks show your consistency in completing habits. '
          'Compare your progress with your partner and tap on any day '
          'to see detailed habit completion information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
