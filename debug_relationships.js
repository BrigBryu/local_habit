#!/usr/bin/env node

// Debug the get_partners RPC function response
const SUPABASE_URL = 'https://ffemtzuqmgqkitbyfvrn.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmZW10enVxbWdxa2l0YnlmdnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3MzQ5NjEsImV4cCI6MjA2NTMxMDk2MX0.7WWQxWCVStoaRXlhKMsLqB5z-67wG65hjr1aJWh1l2U';

async function debugGetPartners() {
  console.log('🔍 Testing get_partners RPC function...\n');
  
  // Get user IDs first
  const accountsResponse = await fetch(`${SUPABASE_URL}/rest/v1/accounts?select=id,username`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  
  const accounts = await accountsResponse.json();
  const user2 = accounts.find(acc => acc.username === 'user2');
  const user3 = accounts.find(acc => acc.username === 'user3');
  
  console.log(`user2 ID: ${user2.id}`);
  console.log(`user3 ID: ${user3.id}\n`);
  
  // Test get_partners for user2 (who is currently logged in)
  console.log('📞 Calling get_partners for user2...');
  const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/get_partners`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      p_user_id: user2.id
    })
  });
  
  if (response.ok) {
    const partners = await response.json();
    console.log('✅ RPC Response:', JSON.stringify(partners, null, 2));
    
    console.log('\n🎯 Expected for user2:');
    console.log('- Should return user3 as partner');
    console.log('- partner_id should be:', user3.id);
    console.log('- partner_username should be: user3');
    
    if (partners.length > 0) {
      console.log('\n📊 Analysis:');
      partners.forEach((partner, index) => {
        console.log(`Partner ${index + 1}:`);
        console.log(`  ID: ${partner.id}`);
        console.log(`  Username: ${partner.username}`);
        console.log(`  Partner ID: ${partner.partner_id}`);
        console.log(`  Partner Username: ${partner.partner_username}`);
        console.log(`  ✅ This looks ${partner.partner_id === user3.id ? 'CORRECT' : 'WRONG'}`);
      });
    }
  } else {
    console.log('❌ RPC call failed:', response.status, response.statusText);
    const errorText = await response.text();
    console.log('Error details:', errorText);
  }
}

debugGetPartners().catch(console.error);