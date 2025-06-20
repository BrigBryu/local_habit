-- Fix auth signup settings for username-as-email strategy
-- This addresses sign-up failures with fake email domains

-- Enable sign-ups (ensure this is enabled in Supabase Dashboard -> Auth -> Settings)
-- Note: This is typically handled in the Dashboard, not SQL

-- Ensure profiles table exists with proper structure
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE NOT NULL CHECK (length(username) >= 3 AND length(username) <= 20),
    display_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read any profile (for username lookup during partner linking)
CREATE POLICY "Allow users to read any profile" ON public.profiles
    FOR SELECT USING (true);

-- Allow users to insert their own profile
CREATE POLICY "Allow users to insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Allow users to update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_id ON public.profiles(id);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER handle_updated_at_profiles
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Comments for documentation
COMMENT ON TABLE public.profiles IS 'User profiles with username mapping for auth users';
COMMENT ON COLUMN public.profiles.username IS 'Unique username for user identification (converted to fake email for auth)';
COMMENT ON COLUMN public.profiles.display_name IS 'Optional display name for user';