#!/usr/bin/env node

// Test the PartnerService get_partners flow exactly as the app does it
const SUPABASE_URL = 'https://ffemtzuqmgqkitbyfvrn.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmZW10enVxbWdxa2l0YnlmdnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3MzQ5NjEsImV4cCI6MjA2NTMxMDk2MX0.7WWQxWCVStoaRXlhKMsLqB5z-67wG65hjr1aJWh1l2U';

async function testPartnerServiceFlow() {
  console.log('🔗 Testing PartnerService flow exactly as Flutter app does...\n');
  
  const user2Id = '3cd85802-29a0-4153-b685-1d9beb2a86be';
  console.log(`Current user (user2): ${user2Id}\n`);
  
  // Step 1: Call get_partners RPC (same as PartnerService.getPartners())
  console.log('📞 Step 1: Calling get_partners RPC...');
  const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/get_partners`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      p_user_id: user2Id
    })
  });
  
  if (!response.ok) {
    console.log(`❌ RPC call failed: ${response.status}`);
    return;
  }
  
  const relationships = await response.json();
  console.log(`✅ Got ${relationships.length} relationships`);
  console.log('Raw relationship data:', JSON.stringify(relationships, null, 2));
  
  // Step 2: Extract partner IDs (same as PartnerHabitsProvider logic)
  console.log('\n📋 Step 2: Processing relationships for habit queries...');
  
  for (const relationship of relationships) {
    console.log(`\n🔍 Processing relationship:`);
    console.log(`  - Relationship ID: ${relationship.id}`);
    console.log(`  - User: ${relationship.username} (${relationship.user_id || 'MISSING'})`);
    console.log(`  - Partner: ${relationship.partner_username} (${relationship.partner_id})`);
    
    const partnerId = relationship.partner_id;
    if (!partnerId) {
      console.log(`  ❌ No partner_id found!`);
      continue;
    }
    
    console.log(`  🎯 Should query habits for partner ID: ${partnerId}`);
    
    // Step 3: Query partner habits (same as RemoteHabitsRepository.partnerHabits())
    console.log(`  📱 Querying habits for ${partnerId}...`);
    
    try {
      const habitsResponse = await fetch(`${SUPABASE_URL}/rest/v1/habits?user_id=eq.${partnerId}`, {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
        }
      });
      
      if (habitsResponse.ok) {
        const habits = await habitsResponse.json();
        console.log(`  ✅ Found ${habits.length} habits for partner ${relationship.partner_username}`);
        habits.forEach(habit => {
          console.log(`    - ${habit.name} (${habit.type})`);
        });
      } else {
        console.log(`  ❌ Failed to query habits: ${habitsResponse.status}`);
      }
    } catch (error) {
      console.log(`  ❌ Error querying habits: ${error.message}`);
    }
  }
  
  console.log('\n🎯 Expected result:');
  console.log('- user2 should see 1 habit from user3');
  console.log('- The habit should be "Bb" (basic type)');
  console.log('- Partner ID should be: e7e719dc-e0a2-488c-a3e0-8c4086366721');
}

testPartnerServiceFlow().catch(console.error);