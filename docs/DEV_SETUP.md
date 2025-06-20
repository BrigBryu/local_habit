# Development Setup Guide

## Overview

This Flutter app uses Supabase for backend services with a username-based authentication system.

## Authentication System

### Fake Email Strategy

The app uses a "username-as-email" authentication strategy where:

1. **User Input**: Users enter a username (e.g., `myuser123`)
2. **Email Conversion**: Username is converted to fake email: `myuser123@test.com`
3. **Supabase Auth**: The fake email is used with Supabase's standard email/password auth
4. **Profile Mapping**: A `profiles` table maps the Supabase user ID to the original username

### Why This Approach?

- **User Experience**: Users only need to remember a username, not an email
- **Supabase Compatibility**: Leverages Supabase's robust email/password authentication
- **Partner Linking**: Users can find each other by username instead of email

## Auth Troubleshooting

### Common Issues

#### 1. Sign-up Fails Silently
**Symptoms**: Tapping "Create Account" or "Quick Test Account" shows loading but no success/error message

**Causes**:
- Invalid email domain in `_usernameToEmail()` method
- Supabase not initialized properly
- Network connectivity issues
- Auth policies blocking sign-ups

**Debug Steps**:
```bash
# Check Flutter console logs for specific errors
fvm flutter run -d [device]

# Look for these log patterns:
# ✅ Good: "User registered and signed in: [username]"
# ❌ Bad: "Registration failed", "SupabaseClientService not initialized"
```

#### 2. "SupabaseClientService not initialized" Error
**Solution**: Ensure `SupabaseClientService.instance.initialize()` is called before `UsernameAuthService.instance.initialize()` in `main.dart`

#### 3. Email Domain Rejected
**Symptoms**: Error messages about "invalid email address"

**Solution**: Update `_usernameToEmail()` in `username_auth_service.dart` to use a valid domain:
```dart
String _usernameToEmail(String username) {
  return '${username.toLowerCase().trim()}@test.com'; // or @yourapp.dev
}
```

### Reset Auth State

If auth gets into a broken state during development:

1. **Clear App Data** (iOS Simulator):
   ```bash
   Device > Erase All Content and Settings
   ```

2. **Clear Supabase Test Users** (if needed):
   ```sql
   -- Run in Supabase SQL Editor
   DELETE FROM auth.users WHERE email LIKE '%@test.com';
   DELETE FROM public.profiles WHERE username LIKE 'user%';
   ```

3. **Restart Flutter App**:
   ```bash
   pkill -f "flutter run"
   fvm flutter run -d [device]
   ```

### Testing Account Creation

Use the built-in Quick Test Account feature:
1. Tap "🚀 QUICK TEST ACCOUNT" button
2. This creates users like `user1@test.com`, `user2@test.com` with password `q1234567`
3. Check Flutter console for success/failure logs

### Database Setup

Ensure the `profiles` table exists with proper structure:
```sql
-- See supabase/sql_snippets/08_fix_auth_signup.sql for complete setup
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE NOT NULL CHECK (length(username) >= 3 AND length(username) <= 20),
    display_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Environment Setup

1. **Copy `.env` file** with Supabase credentials
2. **Run setup commands**:
   ```bash
   fvm flutter pub get
   cd ios && pod install && cd ..  # iOS only
   ```
3. **Start development**:
   ```bash
   fvm flutter run -d "iPhone 16"  # or your preferred device
   ```

## Useful Commands

```bash
# Test auth logic
fvm flutter test test/smoke_test.dart

# Test username auth service
fvm flutter test test/username_auth_service_test.dart

# Full test suite
fvm flutter test

# Hot reload during development
# (press 'r' in the running flutter console)
```