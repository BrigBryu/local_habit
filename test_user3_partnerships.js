#!/usr/bin/env node

const SUPABASE_URL = 'https://ffemtzuqmgqkitbyfvrn.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmZW10enVxbWdxa2l0YnlmdnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3MzQ5NjEsImV4cCI6MjA2NTMxMDk2MX0.7WWQxWCVStoaRXlhKMsLqB5z-67wG65hjr1aJWh1l2U';

const user3Id = 'e7e719dc-e0a2-488c-a3e0-8c4086366721';

async function testUser3Partnerships() {
  console.log('🔍 Testing partnerships for user3:', user3Id);
  
  const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/get_partners`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      p_user_id: user3Id
    })
  });
  
  if (!response.ok) {
    console.log('❌ RPC call failed:', response.status);
    return;
  }
  
  const relationships = await response.json();
  console.log('✅ user3 relationships:', relationships.length);
  console.log('Raw data:', JSON.stringify(relationships, null, 2));
  
  if (relationships.length > 0) {
    console.log('\n🎯 Expected result:');
    console.log('- user3 should see user2 as partner');
    console.log('- user2 has no habits, so should show "partner has no habits yet"');
  } else {
    console.log('\n❌ Problem: user3 has no partnerships!');
    console.log('This explains why emulator B shows no partner data');
  }
}

testUser3Partnerships().catch(console.error);