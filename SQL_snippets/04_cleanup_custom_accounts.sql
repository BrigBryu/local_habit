-- Clean up custom accounts system after migration to Supabase auth
-- WARNING: Only run this after verifying the new auth system works completely

-- Drop custom RPC functions
DROP FUNCTION IF EXISTS create_account(TEXT, TEXT);
DROP FUNCTION IF EXISTS login_account(TEXT);
DROP FUNCTION IF EXISTS link_partner(UUID, TEXT);
DROP FUNCTION IF EXISTS get_partners(UUID);
DROP FUNCTION IF EXISTS remove_partner(UUID, UUID);

-- Drop custom accounts table
DROP TABLE IF EXISTS accounts CASCADE;

-- Note: Keep relationships table as it now references auth.users correctly

SELECT 'Custom accounts system cleaned up successfully' as status;