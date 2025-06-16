-- Fix the link_partner function conflicts and type issues
-- Run this to clean up the database functions

-- Drop the old invite-based link_partner function that conflicts
DROP FUNCTION IF EXISTS link_partner(invite_code_param text);

-- Drop and recreate the correct link_partner function with proper parameter types
DROP FUNCTION IF EXISTS link_partner(uuid, text);

-- Create the correct link_partner function
CREATE OR REPLACE FUNCTION link_partner(p_user_id UUID, p_partner_username TEXT)
RETURNS relationships AS $$
DECLARE
    partner_account accounts;
    result relationships;
    normalized_username TEXT;
BEGIN
    -- Normalize partner username
    normalized_username := LOWER(TRIM(p_partner_username));
    
    -- Find partner account
    SELECT * INTO partner_account
    FROM accounts
    WHERE LOWER(username) = normalized_username;
    
    IF partner_account.id IS NULL THEN
        RAISE EXCEPTION 'Partner username not found: %', p_partner_username;
    END IF;
    
    -- Check for self-partnership
    IF partner_account.id = p_user_id THEN
        RAISE EXCEPTION 'Cannot link to yourself';
    END IF;
    
    -- Check if relationship already exists
    IF EXISTS (
        SELECT 1 FROM relationships 
        WHERE user_id = p_user_id AND partner_id = partner_account.id
    ) THEN
        RAISE EXCEPTION 'Already linked to this partner';
    END IF;
    
    -- Create the relationship
    INSERT INTO relationships (user_id, partner_id)
    VALUES (p_user_id, partner_account.id)
    RETURNING * INTO result;
    
    -- Also create the reverse relationship for bidirectional partnership
    INSERT INTO relationships (user_id, partner_id)
    VALUES (partner_account.id, p_user_id)
    ON CONFLICT (user_id, partner_id) DO NOTHING;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Also fix the get_partners function to handle UUID properly
DROP FUNCTION IF EXISTS get_partners(UUID);

CREATE OR REPLACE FUNCTION get_partners(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    username TEXT,
    partner_id UUID,
    partner_username TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        a1.username,
        r.partner_id,
        a2.username as partner_username,
        r.created_at
    FROM relationships r
    JOIN accounts a1 ON r.user_id = a1.id
    JOIN accounts a2 ON r.partner_id = a2.id
    WHERE r.user_id = p_user_id::UUID
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;