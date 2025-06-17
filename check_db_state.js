#!/usr/bin/env node

// Script to check current database state
const SUPABASE_URL = 'https://ffemtzuqmgqkitbyfvrn.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmZW10enVxbWdxa2l0YnlmdnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3MzQ5NjEsImV4cCI6MjA2NTMxMDk2MX0.7WWQxWCVStoaRXlhKMsLqB5z-67wG65hjr1aJWh1l2U';

async function checkDatabaseState() {
  console.log('🔍 Checking database state...\n');
  
  // Check accounts
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/accounts?select=*`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    if (response.ok) {
      const accounts = await response.json();
      console.log('👥 ACCOUNTS:');
      accounts.forEach(account => {
        console.log(`  - ID: ${account.id}`);
        console.log(`    Username: ${account.username}`);
        console.log(`    Created: ${account.created_at}`);
        console.log('');
      });
    }
  } catch (error) {
    console.log('❌ Failed to fetch accounts:', error.message);
  }
  
  // Check habits
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/habits?select=*`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    if (response.ok) {
      const habits = await response.json();
      console.log('📋 HABITS:');
      habits.forEach(habit => {
        console.log(`  - ID: ${habit.id}`);
        console.log(`    User ID: ${habit.user_id}`);
        console.log(`    Name: ${habit.name}`);
        console.log(`    Type: ${habit.type}`);
        console.log(`    Created: ${habit.created_at}`);
        console.log('');
      });
    }
  } catch (error) {
    console.log('❌ Failed to fetch habits:', error.message);
  }
  
  // Check relationships
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/relationships?select=*`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    if (response.ok) {
      const relationships = await response.json();
      console.log('🤝 RELATIONSHIPS:');
      relationships.forEach(rel => {
        console.log(`  - ID: ${rel.id}`);
        console.log(`    User ID: ${rel.user_id}`);
        console.log(`    Partner ID: ${rel.partner_id}`);
        console.log(`    Status: ${rel.status}`);
        console.log(`    Created: ${rel.created_at}`);
        console.log('');
      });
    }
  } catch (error) {
    console.log('❌ Failed to fetch relationships:', error.message);
  }
}

checkDatabaseState().catch(console.error);