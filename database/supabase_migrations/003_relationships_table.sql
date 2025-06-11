-- Create relationships table for partner linking
CREATE TABLE IF NOT EXISTS relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    partner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    partner_email TEXT,
    invite_code TEXT UNIQUE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    relationship_type TEXT DEFAULT 'partner' CHECK (relationship_type IN ('partner', 'friend', 'family')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '7 days',
    
    -- Ensure no duplicate relationships
    UNIQUE(user_id, partner_id)
);

-- Enable RLS
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own relationships" ON relationships
    FOR SELECT USING (auth.uid() = user_id OR auth.uid() = partner_id);

CREATE POLICY "Users can insert own relationships" ON relationships
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own relationships" ON relationships
    FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = partner_id);

CREATE POLICY "Users can delete own relationships" ON relationships
    FOR DELETE USING (auth.uid() = user_id);

-- Create updated_at trigger
CREATE TRIGGER update_relationships_updated_at 
    BEFORE UPDATE ON relationships 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_relationships_user_id ON relationships(user_id);
CREATE INDEX IF NOT EXISTS idx_relationships_partner_id ON relationships(partner_id);
CREATE INDEX IF NOT EXISTS idx_relationships_invite_code ON relationships(invite_code);
CREATE INDEX IF NOT EXISTS idx_relationships_status ON relationships(status);
CREATE INDEX IF NOT EXISTS idx_relationships_expires_at ON relationships(expires_at);