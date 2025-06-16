import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/streaks/screens/streaks_screen.dart';
import '../../features/streaks/screens/streak_calendar_screen.dart';
import '../../core/auth/auth_wrapper.dart';

class AppRoutes {
  static const String home = '/';
  static const String streaks = '/streaks';
  static const String streaksCalendar = '/streaks/calendar';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: AppRoutes.streaks,
      name: 'streaks',
      builder: (context, state) => const StreaksScreen(),
    ),
    GoRoute(
      path: AppRoutes.streaksCalendar,
      name: 'streaks-calendar',
      builder: (context, state) => const StreakCalendarScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Error: ${state.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

extension AppNavigationExtension on BuildContext {
  /// Navigate to streaks dashboard
  void goToStreaks() => go(AppRoutes.streaks);
  
  /// Navigate to streak calendar
  void goToStreaksCalendar() => go(AppRoutes.streaksCalendar);
  
  /// Push streaks dashboard
  void pushStreaks() => push(AppRoutes.streaks);
  
  /// Push streak calendar
  void pushStreaksCalendar() => push(AppRoutes.streaksCalendar);
}