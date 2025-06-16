-- NOTE: You probably want to run 00-complete-database-setup.sql instead
-- This file is for reference or if you only need the relationships table

-- Create relationships table for partner management
CREATE TABLE IF NOT EXISTS relationships (
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

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_relationships_user_id ON relationships(user_id);
CREATE INDEX IF NOT EXISTS idx_relationships_partner_id ON relationships(partner_id);

-- Enable RLS
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;

-- Create RLS policy for development (only if it doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'relationships' 
        AND policyname = 'Allow all operations on relationships for development'
    ) THEN
        CREATE POLICY "Allow all operations on relationships for development" ON relationships FOR ALL USING (true);
    END IF;
END $$;

SELECT 'Relationships table created successfully' as status;