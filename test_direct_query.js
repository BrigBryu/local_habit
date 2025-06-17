#!/usr/bin/env node

// Test direct Supabase queries to isolate the issue
const SUPABASE_URL = 'https://ffemtzuqmgqkitbyfvrn.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmZW10enVxbWdxa2l0YnlmdnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3MzQ5NjEsImV4cCI6MjA2NTMxMDk2MX0.7WWQxWCVStoaRXlhKMsLqB5z-67wG65hjr1aJWh1l2U';

async function testDirectQueries() {
  console.log('🧪 Testing direct Supabase queries...\n');
  
  const user2Id = '3cd85802-29a0-4153-b685-1d9beb2a86be';
  const user3Id = 'e7e719dc-e0a2-488c-a3e0-8c4086366721';
  
  console.log(`👤 user2 ID: ${user2Id}`);
  console.log(`👤 user3 ID: ${user3Id}\n`);
  
  // Test 1: Query user2's own habits (should be empty)
  console.log('🏠 Test 1: Query user2\'s own habits');
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/habits?user_id=eq.${user2Id}&select=*`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    if (response.ok) {
      const habits = await response.json();
      console.log(`✅ user2 habits: ${habits.length} found`);
      habits.forEach(habit => {
        console.log(`  - ${habit.name} (${habit.type})`);
      });
    } else {
      console.log(`❌ Failed to query user2 habits: ${response.status}`);
    }
  } catch (error) {
    console.log(`❌ Error querying user2 habits: ${error.message}`);
  }
  
  console.log('');
  
  // Test 2: Query user3's habits (should have "Bb")
  console.log('👥 Test 2: Query user3\'s habits (user2\'s partner)');
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/habits?user_id=eq.${user3Id}&select=*`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    if (response.ok) {
      const habits = await response.json();
      console.log(`✅ user3 habits: ${habits.length} found`);
      habits.forEach(habit => {
        console.log(`  - ${habit.name} (${habit.type}) [${habit.id}]`);
        console.log(`    user_id: ${habit.user_id}`);
        console.log(`    created_at: ${habit.created_at}`);
      });
    } else {
      console.log(`❌ Failed to query user3 habits: ${response.status}`);
    }
  } catch (error) {
    console.log(`❌ Error querying user3 habits: ${error.message}`);
  }
  
  console.log('');
  
  // Test 3: Test filtering and response format
  console.log('🔍 Test 3: Test exact query that Flutter app should be doing');
  console.log(`Query: GET /rest/v1/habits?user_id=eq.${user3Id}`);
  
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/habits?user_id=eq.${user3Id}`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Accept': 'application/json'
      }
    });
    
    console.log(`Status: ${response.status}`);
    console.log(`Headers: ${JSON.stringify([...response.headers])}`);
    
    if (response.ok) {
      const text = await response.text();
      console.log(`Raw response: ${text}`);
      
      const habits = JSON.parse(text);
      console.log(`Parsed habits: ${habits.length} records`);
      
      if (habits.length > 0) {
        console.log('✅ This should work in Flutter app!');
        console.log('📝 Sample habit data structure:');
        console.log(JSON.stringify(habits[0], null, 2));
      } else {
        console.log('❌ No habits returned - this is the problem!');
      }
    } else {
      const errorText = await response.text();
      console.log(`❌ Response error: ${errorText}`);
    }
  } catch (error) {
    console.log(`❌ Request error: ${error.message}`);
  }
}

testDirectQueries().catch(console.error);