-- Additional prod-prep tweaks
-- Create invite_codes table and optimize relationship queries

-- Create invite_codes table for 6-character invite system
CREATE TABLE IF NOT EXISTS invite_codes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(6) UNIQUE NOT NULL,
    created_by UUID REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT false,
    used_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    used_at TIMESTAMP WITH TIME ZONE
);

-- Add indexes for invite codes
CREATE INDEX IF NOT EXISTS invite_codes_code_idx ON invite_codes (code);
CREATE INDEX IF NOT EXISTS invite_codes_created_by_idx ON invite_codes (created_by);
CREATE INDEX IF NOT EXISTS invite_codes_expires_at_idx ON invite_codes (expires_at);

-- Add relationship status index for faster partner queries  
CREATE INDEX IF NOT EXISTS relationships_status_idx ON relationships (status);

-- Enable RLS (Row Level Security) on new tables
ALTER TABLE invite_codes ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for invite codes
CREATE POLICY "Users can view their own invite codes" ON invite_codes
    FOR SELECT USING (created_by = auth.uid());

CREATE POLICY "Users can create invite codes" ON invite_codes
    FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY "Users can update their own invite codes" ON invite_codes
    FOR UPDATE USING (created_by = auth.uid());