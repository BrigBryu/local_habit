#!/usr/bin/env dart

// Quick test script to verify local Supabase is working
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // Test connection to local Supabase
  const localSupabaseUrl = 'http://127.0.0.1:54321';
  const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  print('🧪 Testing local Supabase connection...');

  try {
    // Test health endpoint
    final healthResponse =
        await http.get(Uri.parse('$localSupabaseUrl/rest/v1/'));
    print('✅ Health check: ${healthResponse.statusCode}');

    // Test creating a test user
    print('\n📝 Testing user creation...');
    final authResponse = await http.post(
      Uri.parse('$localSupabaseUrl/auth/v1/signup'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
      body: jsonEncode({
        'email': 'device.a.test@example.com',
        'password': 'TestDevice123!',
      }),
    );

    print('User creation response: ${authResponse.statusCode}');
    if (authResponse.statusCode == 200 || authResponse.statusCode == 422) {
      final data = jsonDecode(authResponse.body);
      print('✅ User creation successful (or user already exists)');
      if (data['user'] != null) {
        print('User ID: ${data['user']['id']}');
      }
    } else {
      print('❌ User creation failed: ${authResponse.body}');
    }

    // Test creating invite code function
    print('\n🔗 Testing invite code creation function...');
    final rpcResponse = await http.post(
      Uri.parse('$localSupabaseUrl/rest/v1/rpc/create_invite_code'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
      body: jsonEncode({}),
    );

    print('RPC response: ${rpcResponse.statusCode}');
    print('Response body: ${rpcResponse.body}');

    if (rpcResponse.statusCode == 401) {
      print('⚠️  Expected: Function requires authentication');
    } else if (rpcResponse.statusCode == 200) {
      print('✅ Function accessible');
    }

    // Test table structure
    print('\n📊 Testing table structure...');
    final tablesResponse = await http.get(
      Uri.parse('$localSupabaseUrl/rest/v1/invite_codes?select=*&limit=0'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
    );

    print('Tables query: ${tablesResponse.statusCode}');
    if (tablesResponse.statusCode == 200) {
      print('✅ invite_codes table accessible');
    } else {
      print('❌ Table access failed: ${tablesResponse.body}');
    }

    print('\n🎉 Local Supabase setup verification complete!');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
