-- Create xp_events table for tracking experience points
CREATE TABLE IF NOT EXISTS xp_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    habit_id TEXT,
    event_type TEXT NOT NULL CHECK (event_type IN ('habit_completion', 'streak_bonus', 'bundle_bonus', 'daily_bonus', 'manual_award')),
    xp_amount INTEGER NOT NULL DEFAULT 0,
    multiplier DECIMAL(3,2) DEFAULT 1.0,
    description TEXT DEFAULT '',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE xp_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own xp events" ON xp_events
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own xp events" ON xp_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Partner access policies (users can view partner XP for shared activities)
CREATE POLICY "Users can view partner xp via relationships" ON xp_events
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM relationships r
            WHERE (r.user_id = auth.uid() OR r.partner_id = auth.uid())
            AND r.status = 'accepted'
            AND (r.user_id = user_id OR r.partner_id = user_id)
        )
    );

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_xp_events_user_id ON xp_events(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_events_habit_id ON xp_events(habit_id);
CREATE INDEX IF NOT EXISTS idx_xp_events_event_type ON xp_events(event_type);
CREATE INDEX IF NOT EXISTS idx_xp_events_created_at ON xp_events(created_at);