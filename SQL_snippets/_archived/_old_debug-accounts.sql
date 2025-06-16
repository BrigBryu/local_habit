-- Debug query to see what accounts exist
-- Run this in your Supabase SQL editor to see current accounts

SELECT 
    id,
    username,
    LENGTH(username) as username_length,
    LOWER(username) as normalized_username,
    created_at
FROM accounts 
ORDER BY created_at DESC;

-- Also check if there are any weird characters or spaces
SELECT 
    username,
    LENGTH(username),
    LENGTH(TRIM(username)),
    encode(username::bytea, 'hex') as hex_representation
FROM accounts;