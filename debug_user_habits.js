#!/usr/bin/env node

// Debug script to check which user has which habits
const SUPABASE_URL = 'https://ffemtzuqmgqkitbyfvrn.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmZW10enVxbWdxa2l0YnlmdnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3MzQ5NjEsImV4cCI6MjA2NTMxMDk2MX0.7WWQxWCVStoaRXlhKMsLqB5z-67wG65hjr1aJWh1l2U';

async function debugUserHabits() {
  console.log('🔍 Debugging user habits mapping...\n');
  
  // Get all accounts with their usernames
  const accountsResponse = await fetch(`${SUPABASE_URL}/rest/v1/accounts?select=id,username`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  
  const accounts = await accountsResponse.json();
  console.log('👥 User accounts:');
  accounts.forEach(account => {
    console.log(`  ${account.username}: ${account.id}`);
  });
  console.log('');
  
  // Get all habits with user mapping
  const habitsResponse = await fetch(`${SUPABASE_URL}/rest/v1/habits?select=id,user_id,name,type`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  
  const habits = await habitsResponse.json();
  console.log('📋 Habits by user:');
  
  // Group habits by user ID
  const habitsByUser = {};
  habits.forEach(habit => {
    if (!habitsByUser[habit.user_id]) {
      habitsByUser[habit.user_id] = [];
    }
    habitsByUser[habit.user_id].push(habit);
  });
  
  // Show habits with usernames
  Object.entries(habitsByUser).forEach(([userId, userHabits]) => {
    const account = accounts.find(acc => acc.id === userId);
    const username = account ? account.username : 'Unknown User';
    console.log(`  ${username} (${userId}):`);
    userHabits.forEach(habit => {
      console.log(`    - ${habit.name} (${habit.type}) [${habit.id}]`);
    });
  });
  
  console.log('\n🤝 Partner relationships:');
  const relationshipsResponse = await fetch(`${SUPABASE_URL}/rest/v1/relationships?select=*`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  
  const relationships = await relationshipsResponse.json();
  relationships.forEach(rel => {
    const user = accounts.find(acc => acc.id === rel.user_id);
    const partner = accounts.find(acc => acc.id === rel.partner_id);
    console.log(`  ${user?.username || 'Unknown'} <-> ${partner?.username || 'Unknown'}`);
  });
  
  console.log('\n🎯 Expected behavior:');
  console.log('- user2 should see habits from user3');
  console.log('- user3 should see habits from user2');
  console.log('- Currently logged in: user2');
  console.log('- user2 partner: user3');
  
  const user2Id = accounts.find(acc => acc.username === 'user2')?.id;
  const user3Id = accounts.find(acc => acc.username === 'user3')?.id;
  
  console.log(`\nuser2 habits: ${habitsByUser[user2Id]?.length || 0}`);
  console.log(`user3 habits: ${habitsByUser[user3Id]?.length || 0}`);
}

debugUserHabits().catch(console.error);