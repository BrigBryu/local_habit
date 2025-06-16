import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 Starting minimal app - no async initialization');

  runApp(const ProviderScope(child: MinimalTestApp()));
}

class MinimalTestApp extends StatelessWidget {
  const MinimalTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Level Up - Minimal Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MinimalHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MinimalHomePage extends StatelessWidget {
  const MinimalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Habit Level Up - Working!'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '✅ App is loading successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'This confirms the build environment is working.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Next steps:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• Fix async initialization hanging'),
                    Text('• Test database connections'),
                    Text('• Verify Supabase config'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('💚 Test button pressed - app is responsive');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('App is working! 🎉')),
          );
        },
        tooltip: 'Test App Responsiveness',
        child: const Icon(Icons.check),
      ),
    );
  }
}
