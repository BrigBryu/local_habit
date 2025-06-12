#!/usr/bin/env dart

import 'dart:io';
import 'sync_queue_sim.dart';

/// Standalone test runner for sync queue simulation
void main() async {
  print('🚀 Testing SyncQueue Simulation...\n');
  
  try {
    // Set up test environment
    print('Setting up test environment...');
    
    // Run the simulation
    await runSyncQueueSimulation();
    
    print('\n✅ Sync queue simulation test completed successfully!');
    exit(0);
  } catch (e, stackTrace) {
    print('\n❌ Sync queue simulation test failed:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}