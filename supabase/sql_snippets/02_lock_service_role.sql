-- Hot-patch 02: Lock service-role RLS bypass policies
-- 
-- Removes dangerous service-role policies that bypass RLS security
-- This prevents data leaks and unauthorized access

-- Up: Remove service-role bypass policies
BEGIN;

-- Drop any policies that allow service_role to bypass RLS on habits table
DROP POLICY IF EXISTS "service_role_bypass" ON public.habits;
DROP POLICY IF EXISTS "service_role_full_access" ON public.habits;
DROP POLICY IF EXISTS "Allow service role access" ON public.habits;

-- Drop service-role bypass policies on habit_completions table
DROP POLICY IF EXISTS "service_role_bypass" ON public.habit_completions;
DROP POLICY IF EXISTS "service_role_full_access" ON public.habit_completions;
DROP POLICY IF EXISTS "Allow service role access" ON public.habit_completions;

-- Drop service-role bypass policies on xp_events table
DROP POLICY IF EXISTS "service_role_bypass" ON public.xp_events;
DROP POLICY IF EXISTS "service_role_full_access" ON public.xp_events;
DROP POLICY IF EXISTS "Allow service role access" ON public.xp_events;

-- Drop service-role bypass policies on relationships table
DROP POLICY IF EXISTS "service_role_bypass" ON public.relationships;
DROP POLICY IF EXISTS "service_role_full_access" ON public.relationships;
DROP POLICY IF EXISTS "Allow service role access" ON public.relationships;

-- Drop service-role bypass policies on invite_codes table
DROP POLICY IF EXISTS "service_role_bypass" ON public.invite_codes;
DROP POLICY IF EXISTS "service_role_full_access" ON public.invite_codes;
DROP POLICY IF EXISTS "Allow service role access" ON public.invite_codes;

-- Drop service-role bypass policies on profiles table (if exists)
DROP POLICY IF EXISTS "service_role_bypass" ON public.profiles;
DROP POLICY IF EXISTS "service_role_full_access" ON public.profiles;
DROP POLICY IF EXISTS "Allow service role access" ON public.profiles;

-- Ensure RLS is enabled on all critical tables
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invite_codes ENABLE ROW LEVEL SECURITY;

-- Enable RLS on profiles table if it exists
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
        ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
    END IF;
END$$;

COMMIT;

-- Down: No rollback for security hot-patch
-- Service-role bypasses should remain disabled for security