# Partner System Testing Guide

This document describes the comprehensive testing system for the partner functionality in the Habit Level Up app.

## Overview

The testing system includes:
- **Database migrations** with proper FK constraints and RLS policies
- **SQL unit tests** for all RPC functions
- **Flutter integration tests** for end-to-end partner flow
- **CI/CD pipeline** that runs all tests automatically
- **Development tools** for local testing

## Quick Start

### 1. Apply Database Migration

First, apply the new database migration that replaces fallback UUIDs with real authentication:

```bash
# In Supabase dashboard SQL editor, run:
supabase/migrations/010_partner_system_auth.sql
```

### 2. Set Up Test Environment

Copy the development environment file:
```bash
cp .env.dev .env
```

### 3. Run Local Tests

```bash
# Run Flutter tests
flutter test

# Run integration tests with real authentication
flutter test integration_test/partner_flow_test.dart \
  --dart-define=DEV=true \
  --dart-define=TESTING=true \
  --dart-define=DEVICE=A
```

## Test System Components

### 1. Database Migration (`supabase/migrations/010_partner_system_auth.sql`)

**Features:**
- Real FK constraints on `invite_codes.user_id → auth.users(id)`
- Proper RLS policies (owner-only access)
- Bidirectional relationships table
- Secure RPC functions with authentication checks
- Race condition protection

**Key Functions:**
- `create_invite_code()` - Creates 6-character codes with 7-day expiry
- `link_partner(invite_code)` - Links partners and creates bidirectional relationships
- `remove_partner()` - Removes all relationships for current user

### 2. SQL Unit Tests (`supabase/tests/partner_api_test.sql`)

**Test Coverage:**
- ✅ Create invite code basic functionality
- ✅ Old codes are invalidated when creating new ones
- ✅ Unauthenticated users cannot create codes
- ✅ Partner linking works correctly
- ✅ Expired codes are rejected
- ✅ Self-linking is prevented
- ✅ Duplicate relationships are prevented
- ✅ Used codes cannot be reused
- ✅ Authentication required for all operations
- ✅ Partner removal works
- ✅ RLS policies enforce data isolation

**Run Tests:**
```bash
supabase test db --file supabase/tests/partner_api_test.sql
```

### 3. Flutter Integration Tests (`integration_test/partner_flow_test.dart`)

**Test Scenarios:**
- Device A creates invite code
- Device B links with invite code
- Both devices see partner relationship
- Cannot reuse same invite code
- Cannot link to yourself
- Database contains correct relationship records
- Race condition handling for simultaneous link attempts

**Run Integration Tests:**
```bash
# Device A
flutter test integration_test/partner_flow_test.dart \
  --dart-define=DEV=true \
  --dart-define=TESTING=true \
  --dart-define=DEVICE=A

# Device B
flutter test integration_test/partner_flow_test.dart \
  --dart-define=DEV=true \
  --dart-define=TESTING=true \
  --dart-define=DEVICE=B
```

### 4. Test Authentication (`lib/core/auth/test_sign_in.dart`)

**Features:**
- Automatic test user creation
- Device-specific authentication (DEVICE=A or DEVICE=B)
- Fallback user creation if accounts don't exist
- Clean authentication state management

**Test Users:**
- Device A: `device.a.test@example.com` / `TestDevice123!`
- Device B: `device.b.test@example.com` / `TestDevice456!`

### 5. CI/CD Pipeline (`.github/workflows/ci.yml`)

**Pipeline Jobs:**
1. **Database Tests** - SQL unit tests and schema validation
2. **Flutter Tests** - Unit tests, formatting, and analysis
3. **Integration Tests** - End-to-end partner flow on Android emulator
4. **Build Tests** - Android APK and Web builds
5. **Security Checks** - Dependency scanning and secret detection

**Triggers:**
- Push to `main`, `master`, or `develop` branches
- Pull requests to those branches

## Local Development Workflow

### 1. Reset Test Database

```bash
# Reset database to clean state
psql -h localhost -p 5432 -U postgres -d postgres -f scripts/dev_reset.sql
```

### 2. Test Partner Flow Manually

```bash
# Terminal 1: Start Device A
flutter run -d emulator-5554 \
  --dart-define=DEV=true \
  --dart-define=DEVICE=A

# Terminal 2: Start Device B  
flutter run -d emulator-5556 \
  --dart-define=DEV=true \
  --dart-define=DEVICE=B
```

### 3. Monitor Database

```sql
-- Check invite codes
SELECT code, user_id, expires_at, used_at FROM invite_codes;

-- Check relationships
SELECT user_id, partner_id, status, created_at FROM relationships;
```

## Debugging Common Issues

### Authentication Errors

If you see "Not authenticated" errors:

1. Check test users exist:
```sql
SELECT email FROM auth.users WHERE email LIKE '%test%';
```

2. Verify environment variables:
```bash
cat .env.dev | grep TEST_EMAIL
```

3. Check authentication in app:
```dart
print('Current user: ${TestSignIn.getCurrentUserId()}');
print('Is authenticated: ${TestSignIn.isAuthenticated}');
```

### Database Constraint Errors

If you see FK constraint errors:

1. Ensure test users exist in `auth.users`
2. Run the dev reset script to clean state
3. Check RLS policies are not blocking operations

### Integration Test Failures

Common issues:
- Emulator not starting properly
- Supabase not running locally
- Test users not created
- Race conditions in test execution

## Performance Testing

### Load Testing Partner Creation

```sql
-- Simulate high load on invite code creation
DO $$
BEGIN
  FOR i IN 1..100 LOOP
    PERFORM create_invite_code();
  END LOOP;
END $$;
```

### Concurrent Link Testing

```sql
-- Test race conditions
SELECT link_partner('ABC123'), link_partner('ABC123');
```

## Security Considerations

### RLS Policies

- Users can only see their own invite codes
- Users can only see relationships they're involved in
- All RPC functions require authentication
- No fallback UUIDs in production

### Data Isolation

Each test user operates in complete isolation:
- Cannot see other users' invite codes
- Cannot access other users' relationships
- Cannot perform operations on behalf of other users

## Maintenance

### Updating Test Data

When adding new test scenarios:

1. Update SQL tests in `supabase/tests/partner_api_test.sql`
2. Add Flutter integration tests to `integration_test/partner_flow_test.dart`
3. Update CI pipeline if needed
4. Document new test scenarios in this file

### Database Schema Changes

When modifying the database schema:

1. Create new migration file in `supabase/migrations/`
2. Update SQL tests to cover new functionality
3. Update integration tests for new features
4. Run full CI pipeline to ensure compatibility

## Related Files

- `supabase/migrations/010_partner_system_auth.sql` - Database migration
- `scripts/dev_reset.sql` - Development reset script
- `.env.dev` - Development environment configuration
- `lib/core/auth/test_sign_in.dart` - Test authentication helper
- `integration_test/partner_flow_test.dart` - Integration tests
- `supabase/tests/partner_api_test.sql` - SQL unit tests
- `.github/workflows/ci.yml` - CI/CD pipeline