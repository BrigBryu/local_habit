-- Create habits table with RLS
CREATE TABLE IF NOT EXISTS habits (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('basic', 'avoidance', 'bundle', 'stack')),
    stacked_on_habit_id TEXT,
    bundle_child_ids TEXT[], -- JSON array as text
    parent_bundle_id TEXT,
    timeout_minutes INTEGER,
    available_days INTEGER[], -- Array of weekday numbers 1-7
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_completed TIMESTAMPTZ,
    last_alarm_triggered TIMESTAMPTZ,
    session_start_time TIMESTAMPTZ,
    last_session_started TIMESTAMPTZ,
    session_completed_today BOOLEAN DEFAULT FALSE,
    daily_completion_count INTEGER DEFAULT 0,
    last_completion_count_reset TIMESTAMPTZ,
    daily_failure_count INTEGER DEFAULT 0,
    last_failure_count_reset TIMESTAMPTZ,
    avoidance_success_today BOOLEAN DEFAULT FALSE,
    current_streak INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own habits" ON habits
    FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert own habits" ON habits
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own habits" ON habits
    FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete own habits" ON habits
    FOR DELETE USING (auth.uid() = owner_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_habits_updated_at 
    BEFORE UPDATE ON habits 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_habits_owner_id ON habits(owner_id);
CREATE INDEX IF NOT EXISTS idx_habits_type ON habits(type);
CREATE INDEX IF NOT EXISTS idx_habits_updated_at ON habits(updated_at);