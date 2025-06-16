-- Disable RLS for custom username-based authentication
-- Since we're not using Supabase's built-in auth.uid(), we need to disable RLS
-- or the policies won't work with our custom authentication system

-- Disable Row Level Security for all tables
ALTER TABLE IF EXISTS habits DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS habit_completions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS xp_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS accounts DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS relationships DISABLE ROW LEVEL SECURITY;

-- Drop existing RLS policies that rely on auth.uid()
DROP POLICY IF EXISTS "Users can view their own habits" ON habits;
DROP POLICY IF EXISTS "Users can insert their own habits" ON habits;
DROP POLICY IF EXISTS "Users can update their own habits" ON habits;
DROP POLICY IF EXISTS "Users can delete their own habits" ON habits;

DROP POLICY IF EXISTS "Users can view their own completions" ON habit_completions;
DROP POLICY IF EXISTS "Users can insert their own completions" ON habit_completions;

DROP POLICY IF EXISTS "Users can view their own xp events" ON xp_events;
DROP POLICY IF EXISTS "Users can insert their own xp events" ON xp_events;

-- Note: Since we're using username-based auth and filtering by user_id in application code,
-- we don't need RLS policies. The application handles user isolation through the user_id field.

SELECT 'RLS disabled for custom authentication system' as status;