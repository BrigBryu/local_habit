-- Debug: Check what accounts exist
SELECT 
    id,
    username,
    created_at,
    LENGTH(username) as username_length,
    LOWER(TRIM(username)) as normalized_username
FROM accounts 
ORDER BY created_at DESC;

-- Test the link_partner function manually
-- Replace the UUIDs with actual user IDs from the query above
-- SELECT link_partner('your-user-id-here', 'graceq');