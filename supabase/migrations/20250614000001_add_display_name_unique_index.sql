-- Add display_name column + unique index to profiles table
-- This ensures every user has a unique, non-null display name

-- Add display_name column if it doesn't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS display_name TEXT;

-- Add unique index on display_name (case-insensitive)
CREATE UNIQUE INDEX IF NOT EXISTS profiles_display_name_unique_idx 
ON profiles (LOWER(display_name));

-- Add NOT NULL constraint (after ensuring existing records have values)
-- Note: This should be run after populating existing records with default names
-- ALTER TABLE profiles ALTER COLUMN display_name SET NOT NULL;