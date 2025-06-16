-- Fix for create_account function to handle edge cases better
-- Run this to replace the existing function

CREATE OR REPLACE FUNCTION create_account(p_username TEXT, p_password_hash TEXT)
RETURNS accounts AS $$
DECLARE
    result accounts;
    normalized_username TEXT;
    existing_count INTEGER;
BEGIN
    -- Normalize username (lowercase and trim)
    normalized_username := LOWER(TRIM(p_username));
    
    -- Validate username format
    IF normalized_username = '' OR LENGTH(normalized_username) < 3 THEN
        RAISE EXCEPTION 'Username must be at least 3 characters long';
    END IF;
    
    -- Check if username already exists with more detailed logging
    SELECT COUNT(*) INTO existing_count 
    FROM accounts 
    WHERE LOWER(TRIM(username)) = normalized_username;
    
    IF existing_count > 0 THEN
        RAISE EXCEPTION 'Username already exists: %', normalized_username;
    END IF;
    
    -- Insert new account
    INSERT INTO accounts (username, password_hash)
    VALUES (normalized_username, p_password_hash)
    RETURNING * INTO result;
    
    RETURN result;
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Username already exists: %', normalized_username;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Account creation failed: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;