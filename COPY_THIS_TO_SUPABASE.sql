-- COPY AND PASTE THIS ENTIRE SCRIPT INTO SUPABASE SQL EDITOR
-- Go to: Supabase Dashboard → Your Project → SQL Editor → New Query
-- Then paste this entire content and click "Run"

-- Fix Supabase Realtime Publication and SECURITY DEFINER
-- This enables real-time sync and fixes authentication issues

-- 1. Fix Supabase Realtime Publication
DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime
  FOR TABLE accounts, habits, habit_completions, relationships;

-- 2. Fix RPC functions with SECURITY DEFINER

-- Fix create_account function
CREATE OR REPLACE FUNCTION create_account(p_username TEXT, p_password_hash TEXT)
RETURNS UUID AS $$
DECLARE
    new_id UUID;
    normalized_username TEXT;
BEGIN
    -- Normalize username
    normalized_username := LOWER(TRIM(p_username));
    
    -- Check if username already exists
    IF EXISTS (SELECT 1 FROM accounts WHERE LOWER(username) = normalized_username) THEN
        RAISE EXCEPTION 'Username already exists: %', p_username;
    END IF;
    
    -- Create account
    INSERT INTO accounts (username, password_hash)
    VALUES (p_username, p_password_hash)
    RETURNING id INTO new_id;
    
    RETURN new_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fix login_account function
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

-- Fix link_partner function
CREATE OR REPLACE FUNCTION link_partner(p_user_id UUID, p_partner_username TEXT)
RETURNS UUID AS $$
DECLARE
    partner_account accounts;
    relationship_id UUID;
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
    
    -- Don't allow self-partnership
    IF partner_account.id = p_user_id THEN
        RAISE EXCEPTION 'Cannot link to yourself';
    END IF;
    
    -- Check if relationship already exists
    IF EXISTS (
        SELECT 1 FROM relationships 
        WHERE (user_id = p_user_id AND partner_id = partner_account.id)
           OR (user_id = partner_account.id AND partner_id = p_user_id)
    ) THEN
        RAISE EXCEPTION 'Partnership already exists with %', p_partner_username;
    END IF;
    
    -- Create bidirectional relationship
    INSERT INTO relationships (user_id, partner_id, status, relationship_type)
    VALUES (p_user_id, partner_account.id, 'active', 'partner')
    RETURNING id INTO relationship_id;
    
    -- Create reverse relationship
    INSERT INTO relationships (user_id, partner_id, status, relationship_type)
    VALUES (partner_account.id, p_user_id, 'active', 'partner');
    
    RETURN relationship_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fix get_partners function
CREATE OR REPLACE FUNCTION get_partners(p_user_id UUID)
RETURNS TABLE(
    partner_id UUID,
    partner_username TEXT,
    relationship_status TEXT,
    relationship_type TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id as partner_id,
        a.username as partner_username,
        r.status as relationship_status,
        r.relationship_type as relationship_type,
        r.created_at as created_at
    FROM relationships r
    JOIN accounts a ON r.partner_id = a.id
    WHERE r.user_id = p_user_id
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fix remove_partner function
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

-- 3. Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- 4. Verification
SELECT 'Realtime publication and SECURITY DEFINER functions fixed successfully!' as status;

-- Show what was created
SELECT 'Publication created for tables: accounts, habits, habit_completions, relationships' as publication_info;
SELECT 'All RPC functions updated with SECURITY DEFINER' as security_info;