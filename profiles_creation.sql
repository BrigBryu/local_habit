-- Profiles Table Creation (Simplified)
-- Based on Sprint 1 requirements without complex dependencies

BEGIN;

-- Create update_updated_at_column function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text UNIQUE NOT NULL,
  display_name text,
  created_at timestamp with time zone DEFAULT NOW() NOT NULL,
  updated_at timestamp with time zone DEFAULT NOW() NOT NULL
);

-- Create updated_at trigger for profiles
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policy for profiles
CREATE POLICY "Users can access their own profile"
  ON public.profiles
  FOR ALL
  TO public
  USING (auth.uid() = id);

-- Backfill usernames for existing auth.users
-- Generate username from email (before @ symbol)
INSERT INTO public.profiles (id, username, display_name)
SELECT 
  id,
  SUBSTRING(email FROM '^([^@]+)') AS username,
  SUBSTRING(email FROM '^([^@]+)') AS display_name
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles)
ON CONFLICT (username) DO NOTHING;

-- Handle conflicts by appending user ID suffix
WITH conflicted_users AS (
  SELECT u.id, u.email,
    SUBSTRING(u.email FROM '^([^@]+)') AS base_username
  FROM auth.users u
  WHERE u.id NOT IN (SELECT id FROM public.profiles)
)
INSERT INTO public.profiles (id, username, display_name)
SELECT 
  id,
  base_username || '_' || SUBSTRING(id::text FROM 1 FOR 8) AS username,
  base_username AS display_name
FROM conflicted_users
ON CONFLICT (username) DO NOTHING;

COMMIT;

-- Verification
\echo 'Verification: Profiles table exists'
SELECT COUNT(*) FROM public.profiles;

\echo 'Verification: Sample profiles'
SELECT id, username, display_name FROM public.profiles LIMIT 3;