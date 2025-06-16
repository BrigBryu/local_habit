-- Create relationships table for partner management
-- This stores partnerships between users for habit sharing

-- Create relationships table
CREATE TABLE IF NOT EXISTS relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    partner_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Add compound unique constraint to prevent duplicate relationships
CREATE UNIQUE INDEX IF NOT EXISTS relationships_user_partner_unique_idx 
ON relationships (user_id, partner_id);

-- Add constraint to prevent self-partnerships
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'check_no_self_partnership' 
        AND table_name = 'relationships'
    ) THEN
        ALTER TABLE relationships 
        ADD CONSTRAINT check_no_self_partnership 
        CHECK (user_id != partner_id);
    END IF;
END $$;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS relationships_user_id_idx ON relationships (user_id);
CREATE INDEX IF NOT EXISTS relationships_partner_id_idx ON relationships (partner_id);

-- Add RLS policies for relationships table
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read relationships where they are involved
CREATE POLICY "Users can read own relationships" ON relationships
FOR SELECT USING (
    auth.uid()::text = user_id::text OR 
    auth.uid()::text = partner_id::text
);

-- Policy: Users can insert relationships where they are the user
CREATE POLICY "Users can create relationships" ON relationships
FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Policy: Users can delete relationships where they are involved
CREATE POLICY "Users can delete own relationships" ON relationships
FOR DELETE USING (
    auth.uid()::text = user_id::text OR 
    auth.uid()::text = partner_id::text
);