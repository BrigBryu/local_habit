-- Create habits table for storing user habits
-- This table stores habit data with user separation

-- Create habits table if it doesn't exist
CREATE TABLE IF NOT EXISTS habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL, -- Links to accounts.id
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL DEFAULT 'basic', -- 'basic', 'avoidance', 'bundle', 'stack'
    
    -- Relationship fields
    stacked_on_habit_id UUID REFERENCES habits(id),
    bundle_child_ids TEXT[], -- Array of habit IDs for bundle children
    parent_bundle_id UUID REFERENCES habits(id),
    
    -- Configuration fields
    timeout_minutes INTEGER DEFAULT 30,
    available_days TEXT[], -- Array of weekday names
    
    -- Tracking fields
    current_streak INTEGER DEFAULT 0,
    daily_completion_count INTEGER DEFAULT 0,
    session_completed_today BOOLEAN DEFAULT FALSE,
    avoidance_success_today BOOLEAN DEFAULT TRUE,
    daily_failure_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_completed TIMESTAMPTZ,
    last_alarm_triggered TIMESTAMPTZ,
    session_start_time TIMESTAMPTZ,
    last_session_started TIMESTAMPTZ,
    last_completion_count_reset TIMESTAMPTZ,
    last_failure_count_reset TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES accounts(id) ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_type ON habits(type);
CREATE INDEX IF NOT EXISTS idx_habits_created_at ON habits(created_at);

-- Create habit_completions table for tracking completion history
CREATE TABLE IF NOT EXISTS habit_completions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    xp_awarded INTEGER DEFAULT 0,
    completion_type TEXT DEFAULT 'manual', -- 'manual', 'auto', 'failure'
    notes TEXT
);

-- Create indexes for habit_completions
CREATE INDEX IF NOT EXISTS idx_habit_completions_habit_id ON habit_completions(habit_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_user_id ON habit_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_completed_at ON habit_completions(completed_at);

-- Create xp_events table for tracking XP history
CREATE TABLE IF NOT EXISTS xp_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    habit_id UUID REFERENCES habits(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL, -- 'habit_completion', 'level_up', 'bonus', etc.
    xp_amount INTEGER NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for xp_events
CREATE INDEX IF NOT EXISTS idx_xp_events_user_id ON xp_events(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_events_habit_id ON xp_events(habit_id);
CREATE INDEX IF NOT EXISTS idx_xp_events_created_at ON xp_events(created_at);

-- Enable Row Level Security
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_events ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for habits (without IF NOT EXISTS)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can view their own habits' AND tablename = 'habits') THEN
        CREATE POLICY "Users can view their own habits"
            ON habits FOR SELECT
            USING (user_id = auth.uid()::UUID);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can insert their own habits' AND tablename = 'habits') THEN
        CREATE POLICY "Users can insert their own habits"
            ON habits FOR INSERT
            WITH CHECK (user_id = auth.uid()::UUID);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update their own habits' AND tablename = 'habits') THEN
        CREATE POLICY "Users can update their own habits"
            ON habits FOR UPDATE
            USING (user_id = auth.uid()::UUID);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete their own habits' AND tablename = 'habits') THEN
        CREATE POLICY "Users can delete their own habits"
            ON habits FOR DELETE
            USING (user_id = auth.uid()::UUID);
    END IF;
END
$$;

-- Grant permissions to authenticated users
GRANT ALL ON habits TO authenticated;
GRANT ALL ON habit_completions TO authenticated;
GRANT ALL ON xp_events TO authenticated;