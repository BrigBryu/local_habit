-- Test the link_partner function manually
-- Run this to debug what's happening

-- First, get the actual UUIDs from your accounts
SELECT 
    id,
    username
FROM accounts 
WHERE username IN ('graceqe', 'graceq')
ORDER BY username;

-- Test the link_partner function manually
-- Replace 'graceqe-uuid-here' with the actual UUID for graceqe from the query above
-- This should help us see exactly what error is happening

-- Example (replace with actual UUIDs):
-- SELECT link_partner('34ffd6fc-5967-4dd2-a01f-8257e3486961'::UUID, 'graceq');

-- Also check if any relationships already exist
SELECT 
    r.id,
    a1.username as user_username,
    a2.username as partner_username,
    r.created_at
FROM relationships r
JOIN accounts a1 ON r.user_id = a1.id
JOIN accounts a2 ON r.partner_id = a2.id
ORDER BY r.created_at DESC;