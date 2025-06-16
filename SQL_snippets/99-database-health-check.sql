-- Database Health Check Script
-- This script verifies that your habit tracking app database is properly configured
-- Run this to ensure everything needed is in place

-- Header
SELECT '=== HABIT TRACKING APP DATABASE HEALTH CHECK ===' as check_title;

-- 1. Check Required Extensions
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp') 
        THEN '✅ uuid-ossp extension is installed'
        ELSE '❌ MISSING: uuid-ossp extension (run: CREATE EXTENSION IF NOT EXISTS "uuid-ossp";)'
    END as extension_check;

-- 2. Check Required Tables
WITH required_tables AS (
    SELECT unnest(ARRAY['accounts', 'habits', 'habit_completions', 'relationships']) as table_name
),
existing_tables AS (
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public'
)
SELECT 
    CASE 
        WHEN et.table_name IS NOT NULL 
        THEN '✅ Table "' || rt.table_name || '" exists'
        ELSE '❌ MISSING: Table "' || rt.table_name || '"'
    END as table_check
FROM required_tables rt
LEFT JOIN existing_tables et ON rt.table_name = et.table_name
ORDER BY rt.table_name;

-- 3. Check Required Table Columns
-- Accounts table columns
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'accounts' AND column_name = 'id' AND data_type = 'uuid'
        ) THEN '✅ accounts.id (UUID) exists'
        ELSE '❌ MISSING: accounts.id (UUID)'
    END as accounts_id_check
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'accounts');

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'accounts' AND column_name = 'username' AND data_type = 'text'
        ) THEN '✅ accounts.username (TEXT) exists'
        ELSE '❌ MISSING: accounts.username (TEXT)'
    END as accounts_username_check
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'accounts');

-- Habits table columns
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'habits' AND column_name = 'user_id' AND data_type = 'uuid'
        ) THEN '✅ habits.user_id (UUID) exists'
        ELSE '❌ MISSING: habits.user_id (UUID)'
    END as habits_user_id_check
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'habits');

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'habits' AND column_name = 'type' AND data_type = 'text'
        ) THEN '✅ habits.type (TEXT) exists'
        ELSE '❌ MISSING: habits.type (TEXT)'
    END as habits_type_check
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'habits');

-- 4. Check Required RPC Functions
WITH required_functions AS (
    SELECT unnest(ARRAY[
        'create_account', 
        'login_account', 
        'link_partner', 
        'get_partners', 
        'remove_partner'
    ]) as function_name
),
existing_functions AS (
    SELECT routine_name as function_name
    FROM information_schema.routines 
    WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'
)
SELECT 
    CASE 
        WHEN ef.function_name IS NOT NULL 
        THEN '✅ Function "' || rf.function_name || '" exists'
        ELSE '❌ MISSING: Function "' || rf.function_name || '"'
    END as function_check
FROM required_functions rf
LEFT JOIN existing_functions ef ON rf.function_name = ef.function_name
ORDER BY rf.function_name;

-- 5. Check Required Indexes
WITH required_indexes AS (
    SELECT unnest(ARRAY[
        'idx_accounts_username_lower',
        'idx_habits_user_id',
        'idx_relationships_user_id',
        'idx_relationships_partner_id'
    ]) as index_name
),
existing_indexes AS (
    SELECT indexname as index_name
    FROM pg_indexes 
    WHERE schemaname = 'public'
)
SELECT 
    CASE 
        WHEN ei.index_name IS NOT NULL 
        THEN '✅ Index "' || ri.index_name || '" exists'
        ELSE '⚠️  MISSING: Index "' || ri.index_name || '" (performance may be affected)'
    END as index_check
FROM required_indexes ri
LEFT JOIN existing_indexes ei ON ri.index_name = ei.index_name
ORDER BY ri.index_name;

-- 6. Check RLS (Row Level Security) Status
SELECT 
    CASE 
        WHEN rowsecurity = true 
        THEN '✅ RLS enabled on "' || tablename || '"'
        ELSE '⚠️  RLS disabled on "' || tablename || '" (may cause permission issues)'
    END as rls_check
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('accounts', 'habits', 'habit_completions', 'relationships')
ORDER BY tablename;

-- 7. Check RLS Policies
WITH required_policies AS (
    SELECT 
        unnest(ARRAY['accounts', 'habits', 'habit_completions', 'relationships']) as table_name,
        'Allow all operations on ' || unnest(ARRAY['accounts', 'habits', 'habit_completions', 'relationships']) || ' for development' as policy_name
),
existing_policies AS (
    SELECT tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
)
SELECT 
    CASE 
        WHEN ep.policyname IS NOT NULL 
        THEN '✅ Policy exists for "' || rp.table_name || '"'
        ELSE '⚠️  MISSING: Development policy for "' || rp.table_name || '"'
    END as policy_check
FROM required_policies rp
LEFT JOIN existing_policies ep ON rp.table_name = ep.tablename AND rp.policy_name = ep.policyname
ORDER BY rp.table_name;

-- 8. Test RPC Functions (Basic Syntax Check)
SELECT '=== TESTING RPC FUNCTIONS ===' as test_title;

-- Test create_account function signature
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.parameters 
            WHERE specific_name IN (
                SELECT specific_name FROM information_schema.routines 
                WHERE routine_name = 'create_account'
            )
            GROUP BY specific_name 
            HAVING COUNT(*) = 2  -- Should have 2 parameters
        ) THEN '✅ create_account function has correct parameters'
        ELSE '❌ create_account function signature issue'
    END as create_account_test;

-- Test get_partners function signature  
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.parameters 
            WHERE specific_name IN (
                SELECT specific_name FROM information_schema.routines 
                WHERE routine_name = 'get_partners'
            )
            GROUP BY specific_name 
            HAVING COUNT(*) = 1  -- Should have 1 parameter
        ) THEN '✅ get_partners function has correct parameters'
        ELSE '❌ get_partners function signature issue'
    END as get_partners_test;

-- 9. Check Table Row Counts
SELECT '=== TABLE DATA STATUS ===' as data_title;

SELECT 
    'accounts' as table_name,
    COUNT(*) as row_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Has test data'
        ELSE 'ℹ️  Empty (ready for new data)'
    END as data_status
FROM accounts
UNION ALL
SELECT 
    'habits' as table_name,
    COUNT(*) as row_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Has test data'
        ELSE 'ℹ️  Empty (ready for new data)'
    END as data_status
FROM habits
UNION ALL
SELECT 
    'relationships' as table_name,
    COUNT(*) as row_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Has test data'
        ELSE 'ℹ️  Empty (ready for new data)'
    END as data_status
FROM relationships
ORDER BY table_name;

-- 10. Overall Health Summary
SELECT '=== OVERALL DATABASE HEALTH SUMMARY ===' as summary_title;

WITH health_checks AS (
    -- Count missing critical components
    SELECT 
        (CASE WHEN NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp') THEN 1 ELSE 0 END) +
        (CASE WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'accounts') THEN 1 ELSE 0 END) +
        (CASE WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'habits') THEN 1 ELSE 0 END) +
        (CASE WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'relationships') THEN 1 ELSE 0 END) +
        (CASE WHEN NOT EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'create_account') THEN 1 ELSE 0 END) +
        (CASE WHEN NOT EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'link_partner') THEN 1 ELSE 0 END) +
        (CASE WHEN NOT EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'get_partners') THEN 1 ELSE 0 END)
        as missing_critical_items
)
SELECT 
    CASE 
        WHEN missing_critical_items = 0 THEN 
            '🎉 DATABASE IS READY! Your habit tracking app should work perfectly.'
        WHEN missing_critical_items <= 2 THEN 
            '⚠️  DATABASE NEEDS MINOR FIXES. Check the issues above and re-run setup script.'
        ELSE 
            '❌ DATABASE NEEDS MAJOR SETUP. Please run SQL_snippets/00-complete-database-setup.sql'
    END as overall_status,
    missing_critical_items as critical_issues_found
FROM health_checks;

-- Instructions
SELECT '=== NEXT STEPS ===' as instructions_title;
SELECT 'If you see any ❌ errors above, run: SQL_snippets/00-complete-database-setup.sql' as instruction;
SELECT 'If you see ⚠️  warnings, they are non-critical but recommended to fix' as warning_note;
SELECT 'If you see 🎉, your database is ready and the app should work!' as success_note;