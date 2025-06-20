# Auth Flow Test Plan

## Manual Acceptance Checklist

### Pre-requisites
- [ ] SQL migrations applied to Supabase:
  - [ ] `01_create_profiles.sql` - Creates profiles table
  - [ ] `02_migrate_habits_fk.sql` - Updates foreign keys to auth.users
  - [ ] `03_rls_policies.sql` - Enables proper RLS policies
- [ ] Flutter app builds without errors
- [ ] Supabase connection working

### Test Cases

#### 1. Fresh User Sign-up Flow
- [ ] **Step 1**: Open app (should show sign-in screen)
- [ ] **Step 2**: Navigate to sign-up screen
- [ ] **Step 3**: Enter unique username (e.g., `testuser123`)
- [ ] **Step 4**: Enter password (minimum 6 characters)
- [ ] **Step 5**: Tap "Create Account"
- [ ] **Expected**: 
  - [ ] Success message shown
  - [ ] User automatically signed in
  - [ ] Main app screen displayed
  - [ ] Empty habits list visible

#### 2. Duplicate Username Validation
- [ ] **Step 1**: Sign out from previous test
- [ ] **Step 2**: Try to sign up with same username
- [ ] **Expected**: 
  - [ ] Error message: "This username is already taken"
  - [ ] User remains on sign-up screen

#### 3. Sign-out / Sign-in Cycle
- [ ] **Step 1**: Sign out from authenticated state
- [ ] **Expected**: 
  - [ ] Returns to sign-in screen immediately
  - [ ] No loading delays
- [ ] **Step 2**: Sign in with same credentials
- [ ] **Expected**:
  - [ ] Successful sign-in
  - [ ] Previous habits (if any) still visible
  - [ ] Username displayed correctly

#### 4. Habit Creation and Persistence
- [ ] **Step 1**: Create a new habit while signed in
- [ ] **Step 2**: Sign out and sign back in
- [ ] **Expected**:
  - [ ] Habit still visible after sign-in
  - [ ] Habit data intact (name, description, etc.)

#### 5. Session Persistence
- [ ] **Step 1**: Sign in successfully
- [ ] **Step 2**: Force-quit and restart app
- [ ] **Expected**:
  - [ ] User remains signed in
  - [ ] No need to enter credentials again
  - [ ] Habits load immediately

#### 6. Multiple Sign-out/Sign-in Cycles
- [ ] **Step 1**: Perform sign-out → sign-in cycle 3 times
- [ ] **Expected**:
  - [ ] All cycles work without issues
  - [ ] No authentication errors
  - [ ] Consistent behavior each time

#### 7. Supabase Session Validation
- [ ] **Step 1**: While signed in, check Flutter logs
- [ ] **Expected**:
  - [ ] `supabase.auth.currentSession` is non-null
  - [ ] Session not expired
  - [ ] `auth.uid()` returns valid UUID

#### 8. Database Verification
- [ ] **Step 1**: Check Supabase dashboard → Authentication
- [ ] **Expected**:
  - [ ] User exists in `auth.users` table
  - [ ] Email format: `{username}@app.local`
- [ ] **Step 2**: Check profiles table
- [ ] **Expected**:
  - [ ] Profile record exists
  - [ ] `id` matches `auth.users.id`
  - [ ] `username` field correct
- [ ] **Step 3**: Check habits table
- [ ] **Expected**:
  - [ ] `user_id` matches `auth.users.id`
  - [ ] No orphaned records

#### 9. RLS Security Test
- [ ] **Step 1**: Open Supabase SQL Editor
- [ ] **Step 2**: Run as anonymous user:
  ```sql
  SELECT * FROM habits;
  ```
- [ ] **Expected**: 0 rows returned
- [ ] **Step 3**: Run:
  ```sql
  SELECT auth.uid();
  ```
- [ ] **Expected**: NULL returned

#### 10. Error Handling
- [ ] **Test 1**: Try sign-in with wrong password
- [ ] **Expected**: Clear error message
- [ ] **Test 2**: Try sign-in with non-existent username
- [ ] **Expected**: Clear error message
- [ ] **Test 3**: Network disconnection during sign-up
- [ ] **Expected**: Graceful error handling

### Performance Checks
- [ ] Sign-up completes in < 3 seconds
- [ ] Sign-in completes in < 2 seconds
- [ ] Habits load in < 2 seconds after sign-in
- [ ] App startup (with session) < 3 seconds

### Log Verification
Check Flutter logs for these success patterns:
- [ ] `Sign up attempt for username: {username}`
- [ ] `Supabase user created: {uuid}`
- [ ] `Profile created for user: {username}`
- [ ] `User registered and signed in: {username}`
- [ ] `Streaming own habits using RLS`
- [ ] `Remote repository initialized for Supabase user: {uuid}`
- [ ] `Session restored for user: {username}`

### Clean-up
- [ ] Test user accounts created can be deleted from Supabase dashboard
- [ ] No lingering test data in habits table
- [ ] App returns to clean state

## Failure Investigation

If any test fails, check:

1. **Flutter logs** for specific error messages
2. **Supabase logs** in dashboard for database errors
3. **Network connectivity** for timeout issues
4. **SQL migration status** - ensure all scripts applied
5. **RLS policies** - verify they're enabled and correct

## Rollback Plan

If major issues found:
1. Disable RLS temporarily: `ALTER TABLE habits DISABLE ROW LEVEL SECURITY;`
2. Revert to commit before auth refactor
3. Investigate and fix issues
4. Re-apply changes incrementally