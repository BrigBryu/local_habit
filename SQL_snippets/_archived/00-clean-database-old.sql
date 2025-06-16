-- Clean database and start fresh
-- WARNING: This will delete all existing data

-- Drop existing tables in correct order (child tables first)
DROP TABLE IF EXISTS habit_completions CASCADE;
DROP TABLE IF EXISTS xp_events CASCADE;
DROP TABLE IF EXISTS habits CASCADE;
DROP TABLE IF EXISTS relationships CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;

-- Drop all functions
DROP FUNCTION IF EXISTS create_account(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS login_account(TEXT) CASCADE;
DROP FUNCTION IF EXISTS link_partner(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS get_partners(UUID) CASCADE;
DROP FUNCTION IF EXISTS remove_partner(UUID, UUID) CASCADE;

SELECT 'Database cleaned successfully' as status;