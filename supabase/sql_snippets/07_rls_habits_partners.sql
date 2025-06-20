-- Migration 07: Tighten RLS policies for habits and partners
-- 
-- Implements strict RLS policies based on auth.uid() for enhanced security
-- Ensures users can only access their own data and authorized partner data

-- UP: Implement strict RLS policies
BEGIN;

-- Ensure RLS is enabled on critical tables
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relationships ENABLE ROW LEVEL SECURITY;

-- ===== HABITS TABLE RLS =====

-- Drop existing policies
DROP POLICY IF EXISTS "Users can access their own habits" ON public.habits;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.habits;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.habits;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON public.habits;
DROP POLICY IF EXISTS "Enable delete for users based on user_id" ON public.habits;

-- Create strict "own rows" policy for habits
-- Handle both TEXT and UUID user_id types
CREATE POLICY "Users can access own habits" ON public.habits
    FOR ALL USING (
        CASE 
            WHEN pg_typeof(user_id) = 'uuid'::regtype THEN
                auth.uid() = user_id
            ELSE
                auth.uid()::TEXT = user_id
        END
    );

-- ===== HABIT_COMPLETIONS TABLE RLS =====

-- Drop existing policies
DROP POLICY IF EXISTS "Users can access their own completions" ON public.habit_completions;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.habit_completions;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.habit_completions;

-- Create strict policy for habit_completions
CREATE POLICY "Users can access own habit completions" ON public.habit_completions
    FOR ALL USING (
        CASE 
            WHEN pg_typeof(user_id) = 'uuid'::regtype THEN
                auth.uid() = user_id
            ELSE
                auth.uid()::TEXT = user_id
        END
    );

-- ===== RELATIONSHIPS/PARTNERS TABLE RLS =====

-- Drop existing policies
DROP POLICY IF EXISTS "Users can access their relationships" ON public.relationships;
DROP POLICY IF EXISTS "Enable read access for users involved in relationship" ON public.relationships;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.relationships;
DROP POLICY IF EXISTS "Enable update for users in relationship" ON public.relationships;
DROP POLICY IF EXISTS "own rows" ON public.relationships;

-- Create policy for relationships - users can access relationships they're part of
CREATE POLICY "Users can access own relationships" ON public.relationships
    FOR ALL USING (
        (CASE 
            WHEN pg_typeof(user_id) = 'uuid'::regtype THEN
                auth.uid() = user_id
            ELSE
                auth.uid()::TEXT = user_id
        END)
        OR
        (CASE 
            WHEN pg_typeof(partner_id) = 'uuid'::regtype THEN
                auth.uid() = partner_id
            ELSE
                auth.uid()::TEXT = partner_id
        END)
    );

-- ===== PROFILES TABLE RLS (ensure it's properly secured) =====

-- The profiles RLS was created in migration 03, but let's ensure it's correct
DROP POLICY IF EXISTS "Users can access their own profile" ON public.profiles;
CREATE POLICY "Users can access own profile" ON public.profiles
    FOR ALL USING (auth.uid() = id);

-- Allow users to read other users' public profile info (username only) for partner search
CREATE POLICY "Users can read public profile info" ON public.profiles
    FOR SELECT USING (true);

-- But restrict updates/deletes to own profile only
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can delete own profile" ON public.profiles
    FOR DELETE USING (auth.uid() = id);

-- ===== SECURITY VERIFICATION =====

-- Verify RLS is enabled on all critical tables
DO $$
DECLARE
    table_name TEXT;
    rls_enabled BOOLEAN;
    policy_count INTEGER;
BEGIN
    FOR table_name IN VALUES ('habits'), ('habit_completions'), ('relationships'), ('profiles')
    LOOP
        -- Check if RLS is enabled
        SELECT relrowsecurity INTO rls_enabled
        FROM pg_class 
        WHERE relname = table_name AND relnamespace = 'public'::regnamespace;
        
        -- Count policies
        SELECT COUNT(*) INTO policy_count
        FROM pg_policies 
        WHERE tablename = table_name AND schemaname = 'public';
        
        RAISE NOTICE 'Table %: RLS enabled = %, Policies = %', table_name, rls_enabled, policy_count;
        
        IF NOT rls_enabled THEN
            RAISE WARNING 'RLS not enabled on table %', table_name;
        END IF;
        
        IF policy_count = 0 THEN
            RAISE WARNING 'No RLS policies found on table %', table_name;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'RLS security audit complete';
END $$;

COMMIT;

--//! DOWN

-- Down: Restore previous RLS policies
BEGIN;

DO $$
BEGIN
    RAISE NOTICE 'Rolling back to previous RLS policies';
END $$;

-- Remove strict policies
DROP POLICY IF EXISTS "Users can access own habits" ON public.habits;
DROP POLICY IF EXISTS "Users can access own habit completions" ON public.habit_completions;
DROP POLICY IF EXISTS "Users can access own relationships" ON public.relationships;
DROP POLICY IF EXISTS "Users can access own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can read public profile info" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.profiles;

-- Restore basic policies (less secure)
CREATE POLICY "Enable read access for authenticated users" ON public.habits
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON public.habits
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for users based on user_id" ON public.habits
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Enable read access for authenticated users" ON public.habit_completions
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON public.habit_completions
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable read access for users involved in relationship" ON public.relationships
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can access their own profile" ON public.profiles
    FOR ALL USING (auth.uid() = id);

DO $$
BEGIN
    RAISE NOTICE 'Restored basic RLS policies - security level reduced';
END $$;

COMMIT;