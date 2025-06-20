-- Migration 04: Migrate habits.user_id foreign key to auth.users.id
-- 
-- Updates the habits table to properly reference auth.users.id instead of string user_id
-- This ensures referential integrity and proper user-habit relationships

-- UP: Migrate habits foreign key
BEGIN;

-- First, let's check current habits table structure and data
DO $$
DECLARE 
    invalid_count INTEGER;
BEGIN
    -- Count habits with user_id not in auth.users
    SELECT COUNT(*) INTO invalid_count
    FROM public.habits h
    LEFT JOIN auth.users u ON h.user_id::UUID = u.id
    WHERE u.id IS NULL;
    
    RAISE NOTICE 'Found % habits with invalid user_id references', invalid_count;
    
    -- If there are invalid references, we'll need to handle them
    IF invalid_count > 0 THEN
        RAISE NOTICE 'Cleaning up invalid habit references...';
        
        -- Option 1: Delete orphaned habits (safer for data integrity)
        DELETE FROM public.habits 
        WHERE user_id NOT IN (
            SELECT id::TEXT FROM auth.users
        );
        
        RAISE NOTICE 'Deleted % orphaned habits', invalid_count;
    END IF;
END $$;

-- Add a backup column to store the old user_id temporarily
ALTER TABLE public.habits ADD COLUMN IF NOT EXISTS old_user_id TEXT;

-- Copy current user_id to backup column
UPDATE public.habits SET old_user_id = user_id WHERE old_user_id IS NULL;

-- Update user_id to ensure it matches auth.users.id format
-- First check if user_id is already UUID format or needs conversion
UPDATE public.habits 
SET user_id = u.id::TEXT
FROM auth.users u 
WHERE (
    CASE 
        WHEN habits.user_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' 
        THEN habits.user_id::UUID = u.id
        ELSE false
    END
);

-- Drop existing foreign key constraint if it exists
ALTER TABLE public.habits DROP CONSTRAINT IF EXISTS habits_user_id_fkey;
ALTER TABLE public.habits DROP CONSTRAINT IF EXISTS fk_habits_user_id;

-- Change user_id column type to UUID and add proper foreign key
ALTER TABLE public.habits 
    ALTER COLUMN user_id TYPE UUID USING user_id::UUID,
    ALTER COLUMN user_id SET NOT NULL;

-- Add foreign key constraint to auth.users.id
ALTER TABLE public.habits 
    ADD CONSTRAINT habits_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON public.habits(user_id);

-- Update any existing RLS policies to use the new UUID type
DROP POLICY IF EXISTS "Users can access their own habits" ON public.habits;
CREATE POLICY "Users can access their own habits" ON public.habits
    FOR ALL USING (auth.uid() = user_id);

-- Clean up: Remove backup column after successful migration
-- (Commented out for safety - can be run manually after verification)
-- ALTER TABLE public.habits DROP COLUMN IF EXISTS old_user_id;

COMMIT;

--//! DOWN

-- Down: Revert habits foreign key migration
BEGIN;

-- Restore old_user_id column if it was dropped
ALTER TABLE public.habits ADD COLUMN IF NOT EXISTS old_user_id TEXT;

-- If old_user_id is empty, we can't fully revert, so this is a best-effort rollback
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'habits' AND column_name = 'old_user_id'
        AND table_schema = 'public'
    ) THEN
        -- Drop the UUID foreign key
        ALTER TABLE public.habits DROP CONSTRAINT IF EXISTS habits_user_id_fkey;
        
        -- Restore user_id from backup if available
        UPDATE public.habits 
        SET user_id = old_user_id::UUID 
        WHERE old_user_id IS NOT NULL;
        
        -- Change back to TEXT type
        ALTER TABLE public.habits ALTER COLUMN user_id TYPE TEXT;
        
        -- Drop backup column
        ALTER TABLE public.habits DROP COLUMN old_user_id;
        
        RAISE NOTICE 'Reverted habits.user_id to TEXT type';
    ELSE
        RAISE WARNING 'Cannot fully revert - old_user_id backup column not found';
    END IF;
END $$;

COMMIT;