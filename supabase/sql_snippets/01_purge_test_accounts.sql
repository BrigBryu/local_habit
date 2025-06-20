-- Hot-patch 01: Purge test accounts and data
-- 
-- Removes test accounts and associated data to clean production database
-- This should only be run in production with proper backup

-- Up: Remove test accounts and data
BEGIN;

-- Delete habits owned by test users (via @app.local or %test% pattern emails)
DELETE FROM public.habits 
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email LIKE '%@app.local' OR email LIKE '%test%'
);

-- Delete habit completions for test users
DELETE FROM public.habit_completions 
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email LIKE '%@app.local' OR email LIKE '%test%'
);

-- Delete XP events for test users
DELETE FROM public.xp_events 
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email LIKE '%@app.local' OR email LIKE '%test%'
);

-- Delete relationships involving test users
DELETE FROM public.relationships 
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email LIKE '%@app.local' OR email LIKE '%test%'
) OR partner_id IN (
  SELECT id FROM auth.users 
  WHERE email LIKE '%@app.local' OR email LIKE '%test%'
);

-- Delete invite codes created by test users
DELETE FROM public.invite_codes 
WHERE created_by IN (
  SELECT id FROM auth.users 
  WHERE email LIKE '%@app.local' OR email LIKE '%test%'
);

-- Delete test user profiles (if profiles table exists)
DELETE FROM public.profiles 
WHERE id IN (
  SELECT id FROM auth.users 
  WHERE email LIKE '%@app.local' OR email LIKE '%test%'
);

-- Finally, delete the test users themselves from auth.users
-- Note: This may require superuser privileges
DELETE FROM auth.users 
WHERE email LIKE '%@app.local' OR email LIKE '%test%';

COMMIT;

-- Down: No rollback for security hot-patch
-- Test data should not be restored once purged