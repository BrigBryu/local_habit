-- Migration 03: Create profiles table and backfill usernames
-- 
-- Creates a proper profiles table to store user metadata including usernames
-- Backfills existing users with generated usernames based on email

-- UP: Create profiles table and populate
BEGIN;

-- Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policy for profiles (users can only access their own profile)
CREATE POLICY "Users can access their own profile" ON public.profiles
    FOR ALL USING (auth.uid() = id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Backfill profiles for existing auth.users
-- Generate usernames from email addresses, handling duplicates
WITH user_data AS (
    SELECT 
        id,
        CASE 
            WHEN email LIKE '%@app.local' THEN 
                CONCAT('user_', SUBSTRING(id::TEXT, 1, 8))
            WHEN email IS NOT NULL THEN 
                LOWER(REGEXP_REPLACE(SPLIT_PART(email, '@', 1), '[^a-z0-9]', '', 'g'))
            ELSE 
                CONCAT('user_', SUBSTRING(id::TEXT, 1, 8))
        END as base_username,
        email,
        created_at
    FROM auth.users
    WHERE id NOT IN (SELECT id FROM public.profiles)
),
numbered_users AS (
    SELECT 
        id,
        email,
        created_at,
        base_username,
        ROW_NUMBER() OVER (PARTITION BY base_username ORDER BY created_at) as rn
    FROM user_data
),
final_usernames AS (
    SELECT 
        id,
        CASE 
            WHEN rn = 1 THEN base_username
            ELSE CONCAT(base_username, '_', rn)
        END as username,
        created_at
    FROM numbered_users
)
INSERT INTO public.profiles (id, username, created_at)
SELECT id, username, created_at
FROM final_usernames
ON CONFLICT (id) DO NOTHING;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at);

COMMIT;

--//! DOWN

-- Down: Remove profiles table and related objects
BEGIN;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

COMMIT;