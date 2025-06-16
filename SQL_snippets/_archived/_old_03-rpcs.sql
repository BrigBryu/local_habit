-- Create RPC functions for authentication and partner management
-- These functions provide the API for the Flutter app to interact with the database

-- Function to create a new account with username and hashed password
CREATE OR REPLACE FUNCTION create_account(p_username TEXT, p_password_hash TEXT)
RETURNS accounts AS $$
DECLARE
    result accounts;
    normalized_username TEXT;
BEGIN
    -- Normalize username (lowercase and trim)
    normalized_username := LOWER(TRIM(p_username));
    
    -- Validate username format
    IF normalized_username = '' OR LENGTH(normalized_username) < 3 THEN
        RAISE EXCEPTION 'Username must be at least 3 characters long';
    END IF;
    
    -- Check if username already exists
    IF EXISTS (SELECT 1 FROM accounts WHERE LOWER(username) = normalized_username) THEN
        RAISE EXCEPTION 'Username already exists';
    END IF;
    
    -- Insert new account
    INSERT INTO accounts (username, password_hash)
    VALUES (normalized_username, p_password_hash)
    RETURNING * INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to authenticate and return account info
CREATE OR REPLACE FUNCTION login_account(p_username TEXT)
RETURNS accounts AS $$
DECLARE
    result accounts;
BEGIN
    SELECT * INTO result
    FROM accounts
    WHERE LOWER(username) = LOWER(TRIM(p_username));
    
    -- Return the account (password verification happens in Dart)
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to link a partner by username
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

-- Function to remove a partner relationship
CREATE OR REPLACE FUNCTION remove_partner(p_user_id UUID, p_partner_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Remove both directions of the relationship
    DELETE FROM relationships 
    WHERE (user_id = p_user_id AND partner_id = p_partner_id) 
       OR (user_id = p_partner_id AND partner_id = p_user_id);
    
    RETURN FOUND;
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