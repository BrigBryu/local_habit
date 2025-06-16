-- Check what columns exist in the habits table
SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'habits' 
ORDER BY ordinal_position;