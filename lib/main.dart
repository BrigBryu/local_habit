import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/shop/presentation/widgets/streak_notification_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Local-only app startup completed - launching UI');

  // Launch offline app
  runApp(const ProviderScope(child: LocalHabitApp()));
}

class LocalHabitApp extends ConsumerWidget {
  const LocalHabitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(currentThemeDataProvider);
    final isLoading = ref.watch(isThemeLoadingProvider);

    if (isLoading) {
      return MaterialApp(
        title: 'Local Habit',
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return StreakNotificationListener(
      child: MaterialApp(
        title: 'Local Habit',
        theme: themeData,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
