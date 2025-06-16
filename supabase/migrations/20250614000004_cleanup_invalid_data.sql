-- Cleanup migration: remove Bob↔Bob self-partnerships, set default names
-- Removes invalid self-partnerships and populates missing display names

-- Remove invalid self-partnerships from relationships table
DELETE FROM relationships 
WHERE user_id_1 = user_id_2 
   OR user_id = partner_id;

-- Set default display names for profiles without them
UPDATE profiles 
SET display_name = CASE 
    WHEN id LIKE '%alice%' THEN 'Alice'
    WHEN id LIKE '%bob%' THEN 'Bob'
    WHEN id LIKE '%charlie%' THEN 'Charlie'
    WHEN id LIKE '%frank%' THEN 'Frank'
    ELSE 'User' || SUBSTRING(id::text, 1, 8)
END,
updated_at = NOW()
WHERE display_name IS NULL OR display_name = '';

-- Remove any duplicate display names by appending numbers
WITH duplicates AS (
    SELECT id, display_name, 
           ROW_NUMBER() OVER (PARTITION BY LOWER(display_name) ORDER BY created_at) as rn
    FROM profiles
)
UPDATE profiles 
SET display_name = display_name || '_' || duplicates.rn,
    updated_at = NOW()
FROM duplicates 
WHERE profiles.id = duplicates.id 
  AND duplicates.rn > 1;