import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/flexible_theme_system.dart';
import 'widgets/app_scaffold.dart';
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
    final colors = ref.watchColors;

    return StreakNotificationListener(
      child: MaterialApp(
        title: 'Local Habit',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: colors.draculaBackground,
          primaryColor: colors.draculaPink,
          colorScheme: ColorScheme.dark(
            primary: colors.draculaPink,
            secondary: colors.draculaPurple,
            surface: colors.draculaCurrentLine,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: colors.draculaBackground,
            foregroundColor: colors.draculaForeground,
          ),
        ),
        home: const AppScaffold(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
