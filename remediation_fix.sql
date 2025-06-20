-- Sprint 1 Remediation Script
-- Execute the fixes identified in the migration report

BEGIN;

-- Fix 1: Complete XP system removal
-- Drop XP tables that were recreated during rollback
DROP TABLE IF EXISTS public.levels CASCADE;
DROP TABLE IF EXISTS public.xp_events CASCADE;

-- Remove XP-related columns from habit_completions
ALTER TABLE public.habit_completions DROP COLUMN IF EXISTS xp_awarded;

-- Fix 2: Remove overly permissive development policies
-- Only keep the essential auth.uid() policies
DROP POLICY IF EXISTS "Allow all operations on habits for development" ON public.habits;
DROP POLICY IF EXISTS "Allow all operations on relationships for development" ON public.relationships;

-- Fix 3: Apply simple habits FK migration without regex issues
-- First ensure habits.user_id is UUID type
ALTER TABLE public.habits 
  ALTER COLUMN user_id TYPE uuid USING user_id::uuid;

-- Add the foreign key constraint
ALTER TABLE public.habits 
  ADD CONSTRAINT habits_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON public.habits(user_id);

-- Add basic RLS policy for habits
CREATE POLICY "Users can access their own habits"
  ON public.habits
  FOR ALL
  TO public
  USING (auth.uid() = user_id);

-- Enable RLS on habits table
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

COMMIT;

-- Verification queries
\echo 'Verification: Tables should not include XP system'
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('levels', 'xp_events');

\echo 'Verification: Habits table structure'
\d+ habits;

\echo 'Verification: RLS policies on habits'
SELECT schemaname, tablename, policyname, permissive, cmd, qual 
FROM pg_policies 
WHERE tablename = 'habits';