-- NOTE: You probably want to run 00-complete-database-setup.sql instead
-- This file is for reference or if you only need the accounts table

-- Create accounts table for username-based authentication
CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create unique index for case-insensitive username lookup
CREATE UNIQUE INDEX IF NOT EXISTS idx_accounts_username_lower ON accounts (LOWER(username));

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_accounts_created_at ON accounts(created_at);

-- Enable RLS
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;

-- Create RLS policy for development (only if it doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'accounts' 
        AND policyname = 'Allow all operations on accounts for development'
    ) THEN
        CREATE POLICY "Allow all operations on accounts for development" ON accounts FOR ALL USING (true);
    END IF;
END $$;

SELECT 'Accounts table created successfully' as status;