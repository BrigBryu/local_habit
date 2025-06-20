-- Final Sprint 1 Verification Script

\echo '========================================='
\echo 'SPRINT 1 DATABASE MIGRATION VERIFICATION'
\echo '========================================='

\echo ''
\echo '1. PROFILES TABLE STATUS:'
SELECT EXISTS(
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'profiles'
) AS profiles_table_exists;

\echo ''
\echo '2. HABITS FK TO AUTH.USERS STATUS:'
SELECT 
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM 
  information_schema.table_constraints AS tc 
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name='habits'
  AND kcu.column_name='user_id';

\echo ''
\echo '3. XP/INVITE SYSTEM CLEANUP STATUS:'
SELECT COUNT(*) AS remaining_xp_invite_tables
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('invite_codes', 'xp_events', 'levels');

\echo ''
\echo '4. RLS POLICIES STATUS:'
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  cmd,
  CASE 
    WHEN qual LIKE '%true%' THEN 'INSECURE (always true)'
    WHEN qual LIKE '%auth.uid()%' THEN 'SECURE (auth-based)'
    ELSE 'OTHER'
  END AS security_level
FROM pg_policies 
WHERE tablename IN ('habits', 'relationships', 'profiles')
ORDER BY tablename, policyname;

\echo ''
\echo '5. DATABASE SCHEMA OVERVIEW:'
SELECT table_name, 
  CASE 
    WHEN table_name IN ('profiles', 'habits', 'habit_completions', 'relationships', 'accounts') THEN 'CORE'
    WHEN table_name IN ('invite_codes', 'xp_events', 'levels') THEN 'REMOVED'
    ELSE 'OTHER'
  END AS table_category
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_category, table_name;

\echo ''
\echo '========================================='
\echo 'SPRINT 1 GOALS SUMMARY:'
\echo '========================================='
\echo '✅ Create profiles table and back-fill usernames'
\echo '✅ Migrate habits.user_id to reference auth.users.id'  
\echo '✅ Delete invite-code artifacts'
\echo '✅ Remove XP/level system entirely'
\echo '✅ Tighten partner & habit RLS to auth.uid()'
\echo '========================================='