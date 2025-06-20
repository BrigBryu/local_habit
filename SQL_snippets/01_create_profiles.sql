-- Create profiles table to map auth.users to usernames
-- This bridges Supabase's built-in auth with our username-only UI

CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create unique index for case-insensitive username lookup
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_username_lower 
ON profiles (LOWER(username));

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON profiles(created_at);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policy for profiles
CREATE POLICY "Users can read own profile" ON profiles
FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON profiles
FOR UPDATE USING (id = auth.uid());

-- Service role can manage all profiles (for registration)
CREATE POLICY "Service role can manage profiles" ON profiles
FOR ALL USING (auth.role() = 'service_role');

SELECT 'Profiles table created successfully' as status;