import 'package:args/args.dart';
import 'package:logger/logger.dart';
import 'package:habit_level_up/core/sync/sync_queue.dart';
import 'package:habit_level_up/core/network/supabase_client.dart';
import 'package:habit_level_up/core/auth/auth_service.dart';
import 'package:habit_level_up/core/sync/sync_database.dart';

/// Development CLI tool for habit_level_up
/// Usage: dart tooling/dev_cli.dart [command] [args]
class DevCLI {
  final Logger _logger = Logger();
  late SyncQueue _syncQueue;
  
  Future<void> run(List<String> arguments) async {
    final parser = ArgParser();
    parser.addCommand('sync');
    parser.addCommand('supabase');
    parser.addFlag('help', abbr: 'h', help: 'Show help information');
    
    // Add subcommand parsers
    final syncParser = parser.commands['sync']!;
    syncParser.addCommand('ls');
    syncParser.addCommand('clear');
    syncParser.addFlag('help', abbr: 'h');
    
    final supabaseParser = parser.commands['supabase']!;
    supabaseParser.addCommand('ping');
    supabaseParser.addFlag('help', abbr: 'h');
    
    try {
      final results = parser.parse(arguments);
      
      if (results['help'] || arguments.isEmpty) {
        _printHelp(parser);
        return;
      }
      
      final command = results.command;
      if (command == null) {
        print('No command specified. Use --help for usage information.');
        return;
      }
      
      await _initializeServices();
      
      switch (command.name) {
        case 'sync':
          await _handleSyncCommand(command);
          break;
        case 'supabase':
          await _handleSupabaseCommand(command);
          break;
        default:
          print('Unknown command: ${command.name}');
          _printHelp(parser);
      }
    } catch (e) {
      print('Error: $e');
      _printHelp(parser);
    }
  }
  
  Future<void> _initializeServices() async {
    try {
      await SupabaseClientService.instance.initialize();
      await AuthService.init();
      
      final syncDb = SyncDatabase();
      await syncDb.initialize();
      _syncQueue = SyncQueue(syncDb);
      
      _logger.d('Services initialized successfully');
    } catch (e) {
      _logger.w('Failed to initialize some services: $e');
    }
  }
  
  Future<void> _handleSyncCommand(ArgResults command) async {
    final subcommand = command.command;
    
    if (subcommand == null || command['help']) {
      _printSyncHelp();
      return;
    }
    
    switch (subcommand.name) {
      case 'ls':
        await _listSyncOperations();
        break;
      case 'clear':
        await _clearSyncOperations();
        break;
      default:
        print('Unknown sync command: ${subcommand.name}');
        _printSyncHelp();
    }
  }
  
  Future<void> _handleSupabaseCommand(ArgResults command) async {
    final subcommand = command.command;
    
    if (subcommand == null || command['help']) {
      _printSupabaseHelp();
      return;
    }
    
    switch (subcommand.name) {
      case 'ping':
        await _pingSupabase();
        break;
      default:
        print('Unknown supabase command: ${subcommand.name}');
        _printSupabaseHelp();
    }
  }
  
  Future<void> _listSyncOperations() async {
    try {
      final operations = await _syncQueue.getAllOperations();
      
      if (operations.isEmpty) {
        print('No sync operations found.');
        return;
      }
      
      print('\nSync Operations:');
      print('─' * 80);
      print('ID\tType\t\tCompleted\tAttempts\tHabit ID');
      print('─' * 80);
      
      for (final op in operations) {
        final id = op.id.toString().padRight(8);
        final type = op.operationType.padRight(15);
        final completed = op.completed ? 'Yes' : 'No';
        final attempts = '${op.attemptCount}/${op.maxRetries}';
        final habitId = op.habitId.substring(0, 8);
        
        print('$id\t$type\t$completed\t\t$attempts\t\t$habitId...');
      }
      
      print('─' * 80);
      print('Total: ${operations.length} operations\n');
      
    } catch (e) {
      print('Error listing sync operations: $e');
    }
  }
  
  Future<void> _clearSyncOperations() async {
    try {
      await _syncQueue.clearCompletedOperations();
      print('✅ Cleared all completed sync operations.');
      
      // Also clear failed operations
      await _syncQueue.clearAllOperations();
      print('✅ Cleared all sync operations.');
      
    } catch (e) {
      print('❌ Error clearing sync operations: $e');
    }
  }
  
  Future<void> _pingSupabase() async {
    try {
      final client = SupabaseClientService.instance.client;
      
      // Simple health check
      final response = await client
          .from('habits')
          .select('count')
          .limit(1);
      
      print('✅ Supabase connection successful');
      print('   Response received: ${response.toString()}');
      
    } catch (e) {
      print('❌ Supabase connection failed: $e');
    }
  }
  
  void _printHelp(ArgParser parser) {
    print('''
Habit Level Up Development CLI

Usage: dart tooling/dev_cli.dart [command] [options]

Available commands:
  sync       Manage sync queue operations
  supabase   Test Supabase connectivity

Global options:
${parser.usage}

Use "dart tooling/dev_cli.dart [command] --help" for more information about a command.
''');
  }
  
  void _printSyncHelp() {
    print('''
Sync queue management commands:

  sync ls     List all sync operations (id, type, completed, attempts)
  sync clear  Purge all sync operations

Options:
  -h, --help  Show this help message
''');
  }
  
  void _printSupabaseHelp() {
    print('''
Supabase connectivity commands:

  supabase ping  Test connection to Supabase (simple GET /rest/v1/)

Options:
  -h, --help     Show this help message
''');
  }
}

void main(List<String> arguments) async {
  final cli = DevCLI();
  await cli.run(arguments);
}