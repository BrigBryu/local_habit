-- Alter existing habits table to match app requirements
-- Add missing columns and fix data types

-- First, change user_id from TEXT to UUID (this might fail if there's existing data)
-- We'll handle this carefully
DO $$
BEGIN
    -- Check if user_id is TEXT and needs to be converted
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'habits' AND column_name = 'user_id' AND data_type = 'text'
    ) THEN
        -- Try to convert existing text user_ids to UUIDs
        -- This will only work if existing user_ids are valid UUIDs
        BEGIN
            ALTER TABLE habits ALTER COLUMN user_id TYPE UUID USING user_id::UUID;
            RAISE NOTICE 'Successfully converted user_id from TEXT to UUID';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Could not convert user_id to UUID, keeping as TEXT for now';
        END;
    END IF;
END
$$;

-- Add missing columns that the app expects
ALTER TABLE habits 
ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'basic',
ADD COLUMN IF NOT EXISTS stacked_on_habit_id UUID,
ADD COLUMN IF NOT EXISTS bundle_child_ids TEXT[],
ADD COLUMN IF NOT EXISTS parent_bundle_id UUID,
ADD COLUMN IF NOT EXISTS timeout_minutes INTEGER DEFAULT 30,
ADD COLUMN IF NOT EXISTS available_days TEXT[],
ADD COLUMN IF NOT EXISTS current_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS daily_completion_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS session_completed_today BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS avoidance_success_today BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS daily_failure_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_completed TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_alarm_triggered TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS session_start_time TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_session_started TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_completion_count_reset TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_failure_count_reset TIMESTAMPTZ;

-- Add foreign key constraints if user_id is now UUID
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'habits' AND column_name = 'user_id' AND data_type = 'uuid'
    ) THEN
        -- Add foreign key constraint to accounts table
        BEGIN
            ALTER TABLE habits 
            ADD CONSTRAINT fk_habits_user_id 
            FOREIGN KEY (user_id) REFERENCES accounts(id) ON DELETE CASCADE;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Could not add foreign key constraint, continuing...';
        END;
        
        -- Add self-referencing foreign keys for stacked habits and bundles
        BEGIN
            ALTER TABLE habits 
            ADD CONSTRAINT fk_habits_stacked_on 
            FOREIGN KEY (stacked_on_habit_id) REFERENCES habits(id);
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Could not add stacked_on foreign key, continuing...';
        END;
        
        BEGIN
            ALTER TABLE habits 
            ADD CONSTRAINT fk_habits_parent_bundle 
            FOREIGN KEY (parent_bundle_id) REFERENCES habits(id);
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Could not add parent_bundle foreign key, continuing...';
        END;
    END IF;
END
$$;

-- Create missing indexes
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_type ON habits(type);
CREATE INDEX IF NOT EXISTS idx_habits_created_at ON habits(created_at);

-- Update type column to have proper values
UPDATE habits SET type = 'basic' WHERE type IS NULL;

SELECT 'Habits table updated successfully' as status;

-- Show the updated structure
SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'habits' 
ORDER BY ordinal_position;