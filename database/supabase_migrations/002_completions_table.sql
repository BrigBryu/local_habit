-- Create completions table for tracking habit completion events
CREATE TABLE IF NOT EXISTS completions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id TEXT NOT NULL,
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    xp_awarded INTEGER DEFAULT 0,
    completion_type TEXT DEFAULT 'manual' CHECK (completion_type IN ('manual', 'automatic', 'bulk')),
    notes TEXT DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE completions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own completions" ON completions
    FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert own completions" ON completions
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own completions" ON completions
    FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete own completions" ON completions
    FOR DELETE USING (auth.uid() = owner_id);

-- Partner access policies (users can view partner completions for shared habits)
CREATE POLICY "Users can view partner completions via relationships" ON completions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM relationships r
            WHERE (r.user_id = auth.uid() OR r.partner_id = auth.uid())
            AND r.status = 'accepted'
            AND (r.user_id = owner_id OR r.partner_id = owner_id)
        )
    );

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_completions_owner_id ON completions(owner_id);
CREATE INDEX IF NOT EXISTS idx_completions_habit_id ON completions(habit_id);
CREATE INDEX IF NOT EXISTS idx_completions_completed_at ON completions(completed_at);
CREATE INDEX IF NOT EXISTS idx_completions_created_at ON completions(created_at);