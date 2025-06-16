-- Complete database setup for habit tracking app with username-based authentication
-- This script creates all tables and RPC functions needed for the app to work
-- Run this in your Supabase SQL editor

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables if they exist to start fresh
DROP TABLE IF EXISTS habit_completions CASCADE;
DROP TABLE IF EXISTS habits CASCADE;
DROP TABLE IF EXISTS relationships CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;

-- Create accounts table for username-based authentication
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create unique index for case-insensitive username lookup
CREATE UNIQUE INDEX idx_accounts_username_lower ON accounts (LOWER(username));
CREATE INDEX idx_accounts_created_at ON accounts(created_at);

-- Create habits table
CREATE TABLE habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL DEFAULT 'basic', -- 'basic', 'avoidance', 'bundle', 'stack'
    frequency_type TEXT DEFAULT 'daily' CHECK (frequency_type IN ('daily', 'weekly', 'monthly')),
    frequency_count INTEGER DEFAULT 1,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- Advanced tracking fields
    current_streak INTEGER DEFAULT 0,
    daily_completion_count INTEGER DEFAULT 0,
    session_completed_today BOOLEAN DEFAULT FALSE,
    avoidance_success_today BOOLEAN DEFAULT TRUE,
    daily_failure_count INTEGER DEFAULT 0,
    timeout_minutes INTEGER DEFAULT 30,
    available_days TEXT[], -- Array of weekday names
    
    -- Relationship fields for advanced habit types
    stacked_on_habit_id UUID REFERENCES habits(id),
    bundle_child_ids UUID[],
    parent_bundle_id UUID REFERENCES habits(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_completed TIMESTAMPTZ,
    last_alarm_triggered TIMESTAMPTZ,
    session_start_time TIMESTAMPTZ,
    last_session_started TIMESTAMPTZ,
    last_completion_count_reset TIMESTAMPTZ,
    last_failure_count_reset TIMESTAMPTZ
);

-- Create habit_completions table
CREATE TABLE habit_completions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    xp_awarded INTEGER DEFAULT 0,
    completion_type TEXT DEFAULT 'manual', -- 'manual', 'auto', 'failure'
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create relationships table for partner linking
CREATE TABLE relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    partner_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked', 'active')),
    relationship_type TEXT DEFAULT 'partner' CHECK (relationship_type IN ('partner', 'friend', 'family')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Ensure no duplicate relationships and no self-partnerships
    UNIQUE(user_id, partner_id),
    CHECK(user_id != partner_id)
);

-- Enable RLS on all tables
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;

-- Create RLS policies that work with custom authentication
-- For development/testing, allow all operations
CREATE POLICY "Allow all operations on accounts for development" ON accounts FOR ALL USING (true);
CREATE POLICY "Allow all operations on habits for development" ON habits FOR ALL USING (true);
CREATE POLICY "Allow all operations on habit_completions for development" ON habit_completions FOR ALL USING (true);
CREATE POLICY "Allow all operations on relationships for development" ON relationships FOR ALL USING (true);

-- Create performance indexes
CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_habits_type ON habits(type);
CREATE INDEX idx_habits_is_active ON habits(is_active);
CREATE INDEX idx_habits_created_at ON habits(created_at);

CREATE INDEX idx_habit_completions_habit_id ON habit_completions(habit_id);
CREATE INDEX idx_habit_completions_user_id ON habit_completions(user_id);
CREATE INDEX idx_habit_completions_completed_at ON habit_completions(completed_at);

CREATE INDEX idx_relationships_user_id ON relationships(user_id);
CREATE INDEX idx_relationships_partner_id ON relationships(partner_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_accounts_updated_at BEFORE UPDATE ON accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON habits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_relationships_updated_at BEFORE UPDATE ON relationships FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RPC FUNCTIONS FOR AUTHENTICATION

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

-- RPC FUNCTIONS FOR PARTNER MANAGEMENT

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
    INSERT INTO relationships (user_id, partner_id, status)
    VALUES (p_user_id, partner_account_id, 'active')
    RETURNING id INTO result_id;
    
    -- Also create the reverse relationship for bidirectional partnership
    INSERT INTO relationships (user_id, partner_id, status)
    VALUES (partner_account_id, p_user_id, 'active')
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
    WHERE r.user_id = p_user_id AND r.status = 'active'
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

-- Grant execute permissions on RPC functions
GRANT EXECUTE ON FUNCTION create_account(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION login_account(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION link_partner(UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_partners(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION remove_partner(UUID, UUID) TO anon, authenticated;

-- Verification queries
SELECT 'Database setup completed successfully!' as status;

-- Show table structures
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('accounts', 'habits', 'habit_completions', 'relationships')
ORDER BY table_name, ordinal_position;

-- Show that tables are empty (no pre-loaded test data)
SELECT 
    'accounts' as table_name, COUNT(*) as row_count FROM accounts
UNION ALL
SELECT 
    'habits' as table_name, COUNT(*) as row_count FROM habits
UNION ALL
SELECT 
    'habit_completions' as table_name, COUNT(*) as row_count FROM habit_completions  
UNION ALL
SELECT 
    'relationships' as table_name, COUNT(*) as row_count FROM relationships;