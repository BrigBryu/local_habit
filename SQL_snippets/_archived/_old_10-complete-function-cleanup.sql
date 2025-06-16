-- Complete cleanup and recreation of all RPC functions
-- This will eliminate all type casting issues

-- Drop ALL variations of these functions to start fresh
DROP FUNCTION IF EXISTS get_partners(UUID);
DROP FUNCTION IF EXISTS get_partners(TEXT);
DROP FUNCTION IF EXISTS get_partners(VARCHAR);
DROP FUNCTION IF EXISTS link_partner(UUID, TEXT);
DROP FUNCTION IF EXISTS link_partner(TEXT, TEXT);
DROP FUNCTION IF EXISTS link_partner(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS link_partner(TEXT);
DROP FUNCTION IF EXISTS remove_partner(UUID, UUID);
DROP FUNCTION IF EXISTS remove_partner(UUID, TEXT);
DROP FUNCTION IF EXISTS remove_partner(TEXT, TEXT);

-- Verify the table structure first
-- Check that accounts.id and relationships.user_id are both UUID type
SELECT 'Checking table structures...' as status;

SELECT 
    column_name, 
    data_type 
FROM information_schema.columns 
WHERE table_name = 'accounts' AND column_name IN ('id', 'username');

SELECT 
    column_name, 
    data_type 
FROM information_schema.columns 
WHERE table_name = 'relationships' AND column_name IN ('id', 'user_id', 'partner_id');

-- Create get_partners function with explicit UUID types
CREATE OR REPLACE FUNCTION get_partners(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    username TEXT,
    partner_id UUID,
    partner_username TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    -- Explicit type conversion to ensure UUID matching
    RETURN QUERY
    SELECT 
        r.id::UUID,
        a1.username::TEXT,
        r.partner_id::UUID,
        a2.username::TEXT as partner_username,
        r.created_at::TIMESTAMPTZ
    FROM relationships r
    JOIN accounts a1 ON r.user_id::UUID = a1.id::UUID
    JOIN accounts a2 ON r.partner_id::UUID = a2.id::UUID
    WHERE r.user_id::UUID = p_user_id::UUID
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create link_partner function with explicit UUID types
CREATE OR REPLACE FUNCTION link_partner(p_user_id UUID, p_partner_username TEXT)
RETURNS UUID AS $$
DECLARE
    partner_account_id UUID;
    result_id UUID;
    normalized_username TEXT;
BEGIN
    -- Normalize partner username
    normalized_username := LOWER(TRIM(p_partner_username));
    
    -- Find partner account ID with explicit UUID casting
    SELECT id::UUID INTO partner_account_id
    FROM accounts
    WHERE LOWER(username) = normalized_username;
    
    IF partner_account_id IS NULL THEN
        RAISE EXCEPTION 'Partner username not found: %', p_partner_username;
    END IF;
    
    -- Check for self-partnership with explicit UUID casting
    IF partner_account_id::UUID = p_user_id::UUID THEN
        RAISE EXCEPTION 'Cannot link to yourself';
    END IF;
    
    -- Check if relationship already exists with explicit UUID casting
    IF EXISTS (
        SELECT 1 FROM relationships 
        WHERE user_id::UUID = p_user_id::UUID AND partner_id::UUID = partner_account_id::UUID
    ) THEN
        RAISE EXCEPTION 'Already linked to this partner';
    END IF;
    
    -- Create the relationship with explicit UUID casting
    INSERT INTO relationships (user_id, partner_id)
    VALUES (p_user_id::UUID, partner_account_id::UUID)
    RETURNING id::UUID INTO result_id;
    
    -- Also create the reverse relationship for bidirectional partnership
    INSERT INTO relationships (user_id, partner_id)
    VALUES (partner_account_id::UUID, p_user_id::UUID)
    ON CONFLICT (user_id, partner_id) DO NOTHING;
    
    RETURN result_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create remove_partner function with explicit UUID types
CREATE OR REPLACE FUNCTION remove_partner(p_user_id UUID, p_partner_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    deleted_count INT;
BEGIN
    -- Remove both directions of the relationship with explicit UUID casting
    DELETE FROM relationships 
    WHERE (user_id::UUID = p_user_id::UUID AND partner_id::UUID = p_partner_id::UUID)
       OR (user_id::UUID = p_partner_id::UUID AND partner_id::UUID = p_user_id::UUID);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    IF deleted_count > 0 THEN
        RETURN TRUE;
    ELSE
        RAISE EXCEPTION 'Partner relationship not found';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Test that the functions are working correctly
SELECT 'Functions created successfully. Testing basic functionality...' as status;

-- Show function signatures to verify they're correct
SELECT 
    proname as function_name,
    pg_get_function_arguments(oid) as arguments,
    pg_get_function_result(oid) as return_type
FROM pg_proc 
WHERE proname IN ('get_partners', 'link_partner', 'remove_partner')
ORDER BY proname;