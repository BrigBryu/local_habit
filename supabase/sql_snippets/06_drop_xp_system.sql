-- Migration 06: Drop XP/Level system entirely
-- 
-- Removes all XP and level-related tables, triggers, functions, and policies
-- This simplifies the application by removing the gamification layer

-- UP: Remove XP/Level system completely
BEGIN;

-- Check and clean up XP-related tables if they exist
DO $$
DECLARE
    table_exists BOOLEAN;
BEGIN
    -- Check for xp_events table
    SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'xp_events') INTO table_exists;
    
    IF table_exists THEN
        -- Drop RLS policies for XP-related tables
        DROP POLICY IF EXISTS "Users can view their own XP events" ON public.xp_events;
        DROP POLICY IF EXISTS "Users can create XP events" ON public.xp_events;
        DROP POLICY IF EXISTS "service_role_bypass" ON public.xp_events;
        DROP POLICY IF EXISTS "service_role_full_access" ON public.xp_events;
        DROP POLICY IF EXISTS "Allow service role access" ON public.xp_events;

        -- Drop indexes on XP-related tables
        DROP INDEX IF EXISTS idx_xp_events_user_id;
        DROP INDEX IF EXISTS idx_xp_events_habit_id;
        DROP INDEX IF EXISTS idx_xp_events_event_type;
        DROP INDEX IF EXISTS idx_xp_events_created_at;
        
        RAISE NOTICE 'Cleaning up xp_events table';
    ELSE
        RAISE NOTICE 'xp_events table does not exist - skipping';
    END IF;

    -- Check for levels table
    SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'levels') INTO table_exists;
    
    IF table_exists THEN
        DROP POLICY IF EXISTS "Everyone can read levels" ON public.levels;
        DROP POLICY IF EXISTS "service_role_bypass" ON public.levels;
        DROP POLICY IF EXISTS "service_role_full_access" ON public.levels;
        DROP POLICY IF EXISTS "Allow service role access" ON public.levels;
        
        DROP INDEX IF EXISTS idx_levels_level;
        DROP INDEX IF EXISTS idx_levels_min_xp;
        
        RAISE NOTICE 'Cleaning up levels table';
    ELSE
        RAISE NOTICE 'levels table does not exist - skipping';
    END IF;
END $$;

-- Drop triggers related to XP system
DROP TRIGGER IF EXISTS trigger_award_xp_on_habit_completion ON public.habit_completions;
DROP TRIGGER IF EXISTS trigger_update_user_level ON public.xp_events;
DROP TRIGGER IF EXISTS update_xp_events_updated_at ON public.xp_events;
DROP TRIGGER IF EXISTS calculate_streak_bonus ON public.habit_completions;

-- Drop functions related to XP system
DROP FUNCTION IF EXISTS public.award_xp_for_habit_completion();
DROP FUNCTION IF EXISTS public.calculate_streak_bonus(UUID, UUID);
DROP FUNCTION IF EXISTS public.update_user_level();
DROP FUNCTION IF EXISTS public.get_user_level(UUID);
DROP FUNCTION IF EXISTS public.get_user_total_xp(UUID);
DROP FUNCTION IF EXISTS public.calculate_level_from_xp(INTEGER);
DROP FUNCTION IF EXISTS public.get_xp_for_level(INTEGER);

-- Remove XP-related columns from other tables
ALTER TABLE public.habit_completions DROP COLUMN IF EXISTS xp_awarded;
ALTER TABLE public.habit_completions DROP COLUMN IF EXISTS streak_bonus;
ALTER TABLE public.habit_completions DROP COLUMN IF EXISTS level_at_completion;

-- Drop XP-related tables
DROP TABLE IF EXISTS public.xp_events CASCADE;
DROP TABLE IF EXISTS public.levels CASCADE;
DROP TABLE IF EXISTS public.user_levels CASCADE;
DROP TABLE IF EXISTS public.achievements CASCADE;
DROP TABLE IF EXISTS public.user_achievements CASCADE;

-- Remove any XP-related views
DROP VIEW IF EXISTS public.user_xp_summary;
DROP VIEW IF EXISTS public.leaderboard;
DROP VIEW IF EXISTS public.user_level_progress;

-- Clean up any remaining XP references in habit_completions if the table exists
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'habit_completions') THEN
        UPDATE public.habit_completions 
        SET completion_type = 'manual' 
        WHERE completion_type IN ('streak_bonus', 'level_bonus', 'achievement');
        RAISE NOTICE 'Cleaned up completion_type references in habit_completions';
    END IF;
END $$;

-- Log the removal
DO $$
DECLARE
    xp_tables_remaining INTEGER;
BEGIN
    -- Count remaining XP-related tables
    SELECT COUNT(*) INTO xp_tables_remaining
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('xp_events', 'levels', 'user_levels', 'achievements', 'user_achievements');
    
    RAISE NOTICE 'XP/Level system removal complete';
    RAISE NOTICE 'Remaining XP tables: %', xp_tables_remaining;
    
    IF xp_tables_remaining = 0 THEN
        RAISE NOTICE 'All XP system components successfully removed';
    ELSE
        RAISE WARNING 'Some XP tables may still exist - manual cleanup required';
    END IF;
END $$;

COMMIT;

--//! DOWN

-- Down: Recreate minimal XP system structure for rollback
BEGIN;

DO $$
BEGIN
    RAISE NOTICE 'Recreating minimal XP system structure for rollback';
    RAISE WARNING 'Business logic and triggers not restored - manual recreation required';
END $$;

-- Recreate levels table
CREATE TABLE IF NOT EXISTS public.levels (
    id SERIAL PRIMARY KEY,
    level INTEGER UNIQUE NOT NULL,
    min_xp INTEGER NOT NULL,
    max_xp INTEGER,
    title TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert basic level structure
INSERT INTO public.levels (level, min_xp, max_xp, title, description) VALUES
(1, 0, 99, 'Beginner', 'Just getting started'),
(2, 100, 249, 'Novice', 'Building momentum'),
(3, 250, 499, 'Apprentice', 'Developing habits'),
(4, 500, 999, 'Practitioner', 'Consistent progress'),
(5, 1000, 1999, 'Expert', 'Mastering habits')
ON CONFLICT (level) DO NOTHING;

-- Recreate xp_events table
CREATE TABLE IF NOT EXISTS public.xp_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    habit_id UUID REFERENCES public.habits(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    xp_amount INTEGER NOT NULL DEFAULT 0,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_events ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policies
CREATE POLICY "Everyone can read levels" ON public.levels FOR SELECT USING (true);
CREATE POLICY "Users can view their own XP events" ON public.xp_events 
    FOR ALL USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_xp_events_user_id ON public.xp_events(user_id);
CREATE INDEX idx_xp_events_created_at ON public.xp_events(created_at);
CREATE INDEX idx_levels_level ON public.levels(level);

-- Add XP column back to habit_completions if it doesn't exist
ALTER TABLE public.habit_completions ADD COLUMN IF NOT EXISTS xp_awarded INTEGER DEFAULT 0;

COMMIT;