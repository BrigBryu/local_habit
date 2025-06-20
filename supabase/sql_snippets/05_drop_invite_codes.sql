-- Migration 05: Drop invite codes system
-- 
-- Removes the entire invite code system including table, policies, and related objects
-- This is part of simplifying the partner system to use direct username search

-- UP: Remove invite codes system
BEGIN;

-- Check if invite_codes table exists and clean it up if it does
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'invite_codes') THEN
        -- Drop RLS policies for invite_codes table
        DROP POLICY IF EXISTS "Users can view invite codes they created" ON public.invite_codes;
        DROP POLICY IF EXISTS "Users can create invite codes" ON public.invite_codes;
        DROP POLICY IF EXISTS "Users can update their invite codes" ON public.invite_codes;
        DROP POLICY IF EXISTS "Anyone can read active invite codes" ON public.invite_codes;
        DROP POLICY IF EXISTS "service_role_bypass" ON public.invite_codes;
        DROP POLICY IF EXISTS "service_role_full_access" ON public.invite_codes;
        DROP POLICY IF EXISTS "Allow service role access" ON public.invite_codes;

        -- Drop any triggers on invite_codes
        DROP TRIGGER IF EXISTS update_invite_codes_updated_at ON public.invite_codes;

        -- Drop indexes on invite_codes table
        DROP INDEX IF EXISTS idx_invite_codes_code;
        DROP INDEX IF EXISTS idx_invite_codes_created_by;
        DROP INDEX IF EXISTS idx_invite_codes_expires_at;
        DROP INDEX IF EXISTS idx_invite_codes_used_by;

        -- Remove any foreign key constraints that reference invite_codes
        ALTER TABLE public.relationships DROP CONSTRAINT IF EXISTS fk_relationships_invite_code;

        -- Remove invite_code columns from relationships if they exist
        ALTER TABLE public.relationships DROP COLUMN IF EXISTS invite_code_id;
        ALTER TABLE public.relationships DROP COLUMN IF EXISTS invite_code;

        -- Drop the invite_codes table entirely
        DROP TABLE public.invite_codes CASCADE;
        
        RAISE NOTICE 'Invite codes table and related objects removed';
    ELSE
        RAISE NOTICE 'Invite codes table does not exist - skipping cleanup';
    END IF;
END $$;

-- Drop any functions specifically for invite codes
DROP FUNCTION IF EXISTS public.generate_invite_code();
DROP FUNCTION IF EXISTS public.cleanup_expired_invite_codes();
DROP FUNCTION IF EXISTS public.validate_invite_code(TEXT);

-- Log the removal
RAISE NOTICE 'Invite codes system cleanup complete';
RAISE NOTICE 'Partner relationships will now use direct username search';

COMMIT;

--//! DOWN

-- Down: No rollback for deprecated invite codes system
BEGIN;

DO $$
BEGIN
    RAISE NOTICE 'Invite codes system rollback not supported - system deprecated for security';
    RAISE NOTICE 'Use new username-based partner system instead';
END $$;

COMMIT;