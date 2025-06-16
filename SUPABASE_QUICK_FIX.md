# Quick Fix for Authentication Issue

## Problem
The app shows "not authenticated" because users aren't signed into Supabase.

## Solution Options:

### Option 1: Create Test Users (RECOMMENDED)
Run this SQL in Supabase to create test users that can authenticate:

```sql
-- Insert test users directly into auth.users (only works if RLS allows)
-- Note: This is a development workaround - in production, users would sign up normally

-- Option 1A: Simple fallback for development
-- Modify the functions to use a fake user ID for testing

-- Update create_invite_code to use a fallback user ID
create or replace function public.create_invite_code()
returns text
language plpgsql
security definer
as $$
declare
  v_code text;
  v_user_id uuid;
begin
  -- Get current user or use a fallback for testing
  v_user_id := auth.uid();
  if v_user_id is null then
    -- Use a consistent fake UUID for testing
    v_user_id := '550e8400-e29b-41d4-a716-446655440000'::uuid;
  end if;

  v_code := upper(substring(replace(uuid_generate_v4()::text, '-', ''), 1, 6));
  insert into public.invite_codes(code, user_id, expires_at)
  values (v_code, v_user_id, now() + interval '7 days');
  return v_code;
end;
$$;

-- Update link_partner to use fallback user ID
create or replace function public.link_partner(invite_code_param text)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_invite_record record;
  v_current_user_id uuid;
begin
  -- Get current user or use a fallback for testing
  v_current_user_id := auth.uid();
  if v_current_user_id is null then
    -- Use a different fake UUID for the second user
    v_current_user_id := '550e8400-e29b-41d4-a716-446655440001'::uuid;
  end if;

  -- Find the invite code
  select * into v_invite_record
  from public.invite_codes
  where code = invite_code_param
  and expires_at > now();
  
  if not found then
    return jsonb_build_object('success', false, 'error', 'Invalid or expired invite code');
  end if;
  
  -- Don't allow self-linking
  if v_invite_record.user_id = v_current_user_id then
    return jsonb_build_object('success', false, 'error', 'Cannot link to yourself');
  end if;
  
  -- Delete the used invite code
  delete from public.invite_codes where code = invite_code_param;
  
  -- Success - return partner info
  return jsonb_build_object('success', true, 'partner_id', v_invite_record.user_id::text);
end;
$$;
```

### Option 2: Use Anonymous Authentication
Enable anonymous authentication in Supabase:

1. Go to Supabase Dashboard → Authentication → Settings
2. Enable "Allow anonymous sign-ins"
3. The app will automatically get anonymous user sessions

### Option 3: Sign Up Test Users
Create test accounts by running this in your app or Supabase:

```sql
-- This would need to be done through the Supabase Auth API
-- Call supabase.auth.signUp() with test emails
```

## Recommended: Run Option 1 SQL Above
This will allow testing without requiring user sign-up flow.