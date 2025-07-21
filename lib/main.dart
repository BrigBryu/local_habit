import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_controller.dart';
import 'widgets/app_scaffold.dart';
import 'core/database/database_service.dart';
import 'core/services/time_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await DatabaseService.initialize();
  await TimeService.instance.initialize();

  debugPrint('Local-only app startup completed - launching UI');

  // Launch offline app
  runApp(const ProviderScope(child: LocalHabitApp()));
}

class LocalHabitApp extends ConsumerWidget {
  const LocalHabitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(currentThemeDataProvider);

    return MaterialApp(
      title: 'Local Habit',
      theme: themeData,
      home: const AppScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}
