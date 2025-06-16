-- Create accounts table for username/password authentication
-- This replaces the in-memory user storage with proper database persistence

-- Create accounts table
CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create unique index on username (case-insensitive)
CREATE UNIQUE INDEX IF NOT EXISTS accounts_username_unique_idx 
ON accounts (LOWER(username));

-- Create function to get account by username (case-insensitive)
CREATE OR REPLACE FUNCTION get_account(p_username TEXT)
RETURNS accounts AS $$
DECLARE
    result accounts;
BEGIN
    SELECT * INTO result
    FROM accounts
    WHERE LOWER(username) = LOWER(TRIM(p_username));
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add RLS policies for accounts table
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own account
CREATE POLICY "Users can read own account" ON accounts
FOR SELECT USING (auth.uid()::text = id::text);

-- Policy: Anyone can insert accounts (for registration)
CREATE POLICY "Anyone can insert accounts" ON accounts
FOR INSERT WITH CHECK (true);

-- Policy: Users can only update their own account
CREATE POLICY "Users can update own account" ON accounts
FOR UPDATE USING (auth.uid()::text = id::text);