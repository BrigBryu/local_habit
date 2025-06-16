-- NOTE: You probably want to run 00-complete-database-setup.sql instead
-- This file is for reference or if you only need the habits tables

-- Create habits table for storing user habits
CREATE TABLE IF NOT EXISTS habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
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
    last_failure_count_reset TIMESTAMPTZ
);

-- Create indexes for performance
CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_habits_type ON habits(type);
CREATE INDEX idx_habits_created_at ON habits(created_at);

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
CREATE INDEX idx_habit_completions_habit_id ON habit_completions(habit_id);
CREATE INDEX idx_habit_completions_user_id ON habit_completions(user_id);
CREATE INDEX idx_habit_completions_completed_at ON habit_completions(completed_at);

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
CREATE INDEX idx_xp_events_user_id ON xp_events(user_id);
CREATE INDEX idx_xp_events_habit_id ON xp_events(habit_id);
CREATE INDEX idx_xp_events_created_at ON xp_events(created_at);

SELECT 'Habits tables created successfully' as status;