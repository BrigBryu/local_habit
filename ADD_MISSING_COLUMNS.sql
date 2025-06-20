-- Add missing current_child_index column to habits table
-- This fixes the habit creation issue where the database rejects inserts due to missing column

-- Add current_child_index column for stack habits (defaults to 0)
ALTER TABLE habits ADD COLUMN IF NOT EXISTS current_child_index INTEGER DEFAULT 0;

-- Verify the column was added
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'habits' 
AND column_name = 'current_child_index';

-- Optional: Update existing habits to have current_child_index = 0 if NULL
UPDATE habits SET current_child_index = 0 WHERE current_child_index IS NULL;

SELECT 'current_child_index column added successfully!' as status;