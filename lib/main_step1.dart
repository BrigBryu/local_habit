import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/network/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 Step 1: Testing with Supabase init only');

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Environment loaded');
  } catch (e) {
    debugPrint('⚠️ Environment load failed: $e');
  }

  // Initialize Supabase with timeout
  try {
    await SupabaseClientService.instance
        .initialize()
        .timeout(const Duration(seconds: 10));
    debugPrint('✅ Supabase initialized');
  } catch (e) {
    debugPrint('⚠️ Supabase init failed: $e');
  }

  debugPrint('🎯 App Startup Completed - launching UI');

  runApp(const ProviderScope(child: Step1TestApp()));
}

class Step1TestApp extends StatelessWidget {
  const Step1TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step 1: Supabase Init Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Step1HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Step1HomePage extends StatelessWidget {
  const Step1HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Step 1: Supabase Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🧪 Step 1: Supabase Initialization',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Testing:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('• Environment variable loading'),
                    const Text('• Supabase client initialization'),
                    const Text('• Basic app responsiveness'),
                    const SizedBox(height: 16),
                    Text(
                      'Supabase Status: ${SupabaseClientService.instance.isInitialized ? "✅ Connected" : "❌ Failed"}',
                      style: TextStyle(
                        color: SupabaseClientService.instance.isInitialized
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('💚 Step 1 test button pressed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Step 1 working! 🎉')),
          );
        },
        child: const Icon(Icons.cloud),
      ),
    );
  }
}
