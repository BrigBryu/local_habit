#!/usr/bin/env node

// Quick script to test database setup using Supabase REST API
const fs = require('fs');
const https = require('https');

const SUPABASE_URL = 'https://ffemtzuqmgqkitbyfvrn.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmZW10enVxbWdxa2l0YnlmdnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3MzQ5NjEsImV4cCI6MjA2NTMxMDk2MX0.7WWQxWCVStoaRXlhKMsLqB5z-67wG65hjr1aJWh1l2U';

async function testDatabaseConnection() {
  console.log('🔍 Testing database connection...');
  
  // Test 1: Check if we can query the accounts table
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/accounts?select=count`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    if (response.ok) {
      console.log('✅ Database connection successful');
      console.log('✅ Accounts table exists');
      
      const data = await response.json();
      console.log(`📊 Accounts table has ${data.length} records`);
    } else {
      console.log('❌ Accounts table missing or inaccessible');
      console.log(`Response: ${response.status} ${response.statusText}`);
    }
  } catch (error) {
    console.log('❌ Database connection failed:', error.message);
  }
  
  // Test 2: Check if we can query the habits table
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/habits?select=count`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    if (response.ok) {
      console.log('✅ Habits table exists');
      const data = await response.json();
      console.log(`📊 Habits table has ${data.length} records`);
    } else {
      console.log('❌ Habits table missing or inaccessible');
      console.log(`Response: ${response.status} ${response.statusText}`);
    }
  } catch (error) {
    console.log('❌ Failed to check habits table:', error.message);
  }
  
  // Test 3: Check if we can query the relationships table
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/relationships?select=count`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    if (response.ok) {
      console.log('✅ Relationships table exists');
      const data = await response.json();
      console.log(`📊 Relationships table has ${data.length} records`);
    } else {
      console.log('❌ Relationships table missing or inaccessible');
      console.log(`Response: ${response.status} ${response.statusText}`);
    }
  } catch (error) {
    console.log('❌ Failed to check relationships table:', error.message);
  }
  
  // Test 4: Test RPC functions
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/get_partners`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        p_user_id: '00000000-0000-0000-0000-000000000000' // Test UUID
      })
    });
    
    if (response.ok) {
      console.log('✅ get_partners RPC function exists');
    } else {
      console.log('❌ get_partners RPC function missing');
      console.log(`Response: ${response.status} ${response.statusText}`);
    }
  } catch (error) {
    console.log('❌ Failed to test RPC functions:', error.message);
  }
}

testDatabaseConnection().catch(console.error);