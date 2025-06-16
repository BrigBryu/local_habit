-- NOTE: You probably want to run 00-complete-database-setup.sql instead
-- This file is for reference or if you only need the RPC functions

-- Create RPC functions for authentication and partner management

-- Function to create a new account
CREATE OR REPLACE FUNCTION create_account(p_username TEXT, p_password_hash TEXT)
RETURNS accounts AS $$
DECLARE
    result accounts;
    normalized_username TEXT;
BEGIN
    -- Normalize username
    normalized_username := LOWER(TRIM(p_username));
    
    -- Check if username already exists
    IF EXISTS (SELECT 1 FROM accounts WHERE LOWER(username) = normalized_username) THEN
        RAISE EXCEPTION 'Username already exists: %', p_username;
    END IF;
    
    -- Create the account
    INSERT INTO accounts (username, password_hash)
    VALUES (p_username, p_password_hash)
    RETURNING * INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to login and get account details
CREATE OR REPLACE FUNCTION login_account(p_username TEXT)
RETURNS accounts AS $$
DECLARE
    result accounts;
    normalized_username TEXT;
BEGIN
    -- Normalize username
    normalized_username := LOWER(TRIM(p_username));
    
    -- Find account
    SELECT * INTO result
    FROM accounts
    WHERE LOWER(username) = normalized_username;
    
    IF result.id IS NULL THEN
        RAISE EXCEPTION 'Username not found: %', p_username;
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to link a partner by username
CREATE OR REPLACE FUNCTION link_partner(p_user_id UUID, p_partner_username TEXT)
RETURNS UUID AS $$
DECLARE
    partner_account_id UUID;
    result_id UUID;
    normalized_username TEXT;
BEGIN
    -- Normalize partner username
    normalized_username := LOWER(TRIM(p_partner_username));
    
    -- Find partner account ID
    SELECT id INTO partner_account_id
    FROM accounts
    WHERE LOWER(username) = normalized_username;
    
    IF partner_account_id IS NULL THEN
        RAISE EXCEPTION 'Partner username not found: %', p_partner_username;
    END IF;
    
    -- Check for self-partnership
    IF partner_account_id = p_user_id THEN
        RAISE EXCEPTION 'Cannot link to yourself';
    END IF;
    
    -- Check if relationship already exists
    IF EXISTS (
        SELECT 1 FROM relationships 
        WHERE user_id = p_user_id AND partner_id = partner_account_id
    ) THEN
        RAISE EXCEPTION 'Already linked to this partner';
    END IF;
    
    -- Create the relationship
    INSERT INTO relationships (user_id, partner_id)
    VALUES (p_user_id, partner_account_id)
    RETURNING id INTO result_id;
    
    -- Also create the reverse relationship for bidirectional partnership
    INSERT INTO relationships (user_id, partner_id)
    VALUES (partner_account_id, p_user_id)
    ON CONFLICT (user_id, partner_id) DO NOTHING;
    
    RETURN result_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get all partners for a user
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
    WHERE r.user_id = p_user_id
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to remove a partner relationship
CREATE OR REPLACE FUNCTION remove_partner(p_user_id UUID, p_partner_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    deleted_count INT;
BEGIN
    -- Remove both directions of the relationship
    DELETE FROM relationships 
    WHERE (user_id = p_user_id AND partner_id = p_partner_id)
       OR (user_id = p_partner_id AND partner_id = p_user_id);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    IF deleted_count > 0 THEN
        RETURN TRUE;
    ELSE
        RAISE EXCEPTION 'Partner relationship not found';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

SELECT 'RPC functions created successfully' as status;