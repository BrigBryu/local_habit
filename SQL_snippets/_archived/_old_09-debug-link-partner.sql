-- Debug the link_partner function step by step
-- Run this to see exactly what's happening

-- First, check what accounts exist
SELECT 'Current accounts:' as debug_step;
SELECT 
    id,
    username,
    LOWER(TRIM(username)) as normalized_username,
    created_at
FROM accounts 
ORDER BY created_at DESC;

-- Check what relationships already exist
SELECT 'Current relationships:' as debug_step;
SELECT 
    r.id,
    a1.username as user_username,
    a2.username as partner_username,
    r.created_at
FROM relationships r
JOIN accounts a1 ON r.user_id = a1.id
JOIN accounts a2 ON r.partner_id = a2.id
ORDER BY r.created_at DESC;

-- Test the link_partner function step by step
-- Replace these UUIDs with actual values from your accounts table above
-- Example test (you'll need to replace with real UUIDs):

-- Get the UUIDs for testing
SELECT 'Test preparation - get UUIDs:' as debug_step;
SELECT 
    'User graceqe UUID: ' || id::text as info
FROM accounts 
WHERE LOWER(username) = 'graceqe'
UNION ALL
SELECT 
    'User graceq UUID: ' || id::text as info
FROM accounts 
WHERE LOWER(username) = 'graceq';

-- Test the function (replace UUIDs with actual values from above)
-- SELECT link_partner('your-graceqe-uuid-here'::UUID, 'graceq');