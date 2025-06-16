# Supabase Database Setup

## Apply Database Migrations

1. **Go to your Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard
   - Select your project: https://ffemtzuqmgqkitbyfvrn.supabase.co

2. **Open SQL Editor:**
   - In the left sidebar, click "SQL Editor"
   - Click "New Query"

3. **Copy and Execute the Migration:**
   - Copy the contents of `supabase/migrations/partner_tables.sql`
   - Paste into the SQL editor
   - Click "Run" to execute

## Quick Migration Script

Copy this SQL and run it in the Supabase SQL Editor:

**FIRST - Run this simple invite code function:**

```sql
-- Enable extension once, safely
create extension if not exists "uuid-ossp";

-- Create invite_codes table if it doesn't exist
create table if not exists public.invite_codes (
  code text primary key,
  user_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  expires_at timestamptz default (now() + interval '1 day')
);

-- Enable RLS on invite_codes table
alter table public.invite_codes enable row level security;

-- RLS policies for invite_codes
create policy "Users can view own invite codes" on public.invite_codes
  for select using (auth.uid() = user_id);

create policy "Users can insert own invite codes" on public.invite_codes
  for insert with check (auth.uid() = user_id);

-- Create the invite code generation function
create or replace function public.create_invite_code()
returns text
language plpgsql
security definer
as $$
declare
  v_code text;
  v_attempts integer := 0;
  v_max_attempts integer := 10;
begin
  -- Get current user
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  -- Generate unique 6-character uppercase code
  loop
    v_code := upper(substring(replace(uuid_generate_v4()::text, '-', ''), 1, 6));
    
    -- Check if code already exists
    if not exists(select 1 from public.invite_codes where code = v_code) then
      exit; -- Found unique code
    end if;
    
    v_attempts := v_attempts + 1;
    if v_attempts >= v_max_attempts then
      raise exception 'Failed to generate unique invite code after % attempts', v_max_attempts;
    end if;
  end loop;

  -- Insert the new invite code
  insert into public.invite_codes(code, user_id, expires_at)
  values (v_code, auth.uid(), now() + interval '7 days');

  return v_code;
end;
$$;

-- Allow callers to execute the function
grant execute on function public.create_invite_code() to anon, authenticated;

-- Create the link_partner function for connecting partners
create or replace function public.link_partner(invite_code_param text)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_invite_record record;
  v_current_user_id uuid;
begin
  -- Get current user
  v_current_user_id := auth.uid();
  if v_current_user_id is null then
    return jsonb_build_object('success', false, 'error', 'Not authenticated');
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

-- Grant permissions for link_partner
grant execute on function public.link_partner(text) to anon, authenticated;
```

**THEN - Run the full partner system (optional):**

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create relationships table for partner linking
CREATE TABLE IF NOT EXISTS relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    partner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    partner_email TEXT,
    invite_code TEXT UNIQUE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    relationship_type TEXT DEFAULT 'partner' CHECK (relationship_type IN ('partner', 'friend', 'family')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '7 days',
    
    -- Ensure no duplicate relationships
    UNIQUE(user_id, partner_id)
);

-- Enable RLS
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own relationships" ON relationships
    FOR SELECT USING (auth.uid() = user_id OR auth.uid() = partner_id);

CREATE POLICY "Users can insert own relationships" ON relationships
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own relationships" ON relationships
    FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = partner_id);

CREATE POLICY "Users can delete own relationships" ON relationships
    FOR DELETE USING (auth.uid() = user_id);

-- Create updated_at trigger
DROP TRIGGER IF EXISTS update_relationships_updated_at ON relationships;
CREATE TRIGGER update_relationships_updated_at 
    BEFORE UPDATE ON relationships 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_relationships_user_id ON relationships(user_id);
CREATE INDEX IF NOT EXISTS idx_relationships_partner_id ON relationships(partner_id);
CREATE INDEX IF NOT EXISTS idx_relationships_invite_code ON relationships(invite_code);
CREATE INDEX IF NOT EXISTS idx_relationships_status ON relationships(status);
CREATE INDEX IF NOT EXISTS idx_relationships_expires_at ON relationships(expires_at);

-- RPC function to create invite code
CREATE OR REPLACE FUNCTION create_invite_code()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id UUID;
    new_code TEXT;
    code_exists BOOLEAN;
    attempts INTEGER := 0;
    max_attempts INTEGER := 10;
    result JSONB;
BEGIN
    -- Get current authenticated user
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
    END IF;
    
    -- Generate unique 6-character code
    LOOP
        new_code := upper(substring(md5(random()::text || current_user_id::text || NOW()::text) from 1 for 6));
        
        SELECT EXISTS(SELECT 1 FROM relationships WHERE invite_code = new_code) INTO code_exists;
        
        attempts := attempts + 1;
        
        EXIT WHEN NOT code_exists OR attempts >= max_attempts;
    END LOOP;
    
    IF code_exists THEN
        RETURN jsonb_build_object('success', false, 'error', 'Failed to generate unique code');
    END IF;
    
    -- Create relationship record with invite code
    INSERT INTO relationships (user_id, invite_code, status)
    VALUES (current_user_id, new_code, 'pending');
    
    RETURN jsonb_build_object('success', true, 'invite_code', new_code);
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- RPC function to link partner by invite code
CREATE OR REPLACE FUNCTION link_partner(invite_code_param TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    relationship_record RECORD;
    current_user_id UUID;
    result JSONB;
BEGIN
    -- Get current authenticated user
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
    END IF;
    
    -- Find the relationship with this invite code
    SELECT * INTO relationship_record
    FROM relationships
    WHERE invite_code = invite_code_param
    AND status = 'pending'
    AND expires_at > NOW();
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Invalid or expired invite code');
    END IF;
    
    -- Don't allow self-linking
    IF relationship_record.user_id = current_user_id THEN
        RETURN jsonb_build_object('success', false, 'error', 'Cannot link to yourself');
    END IF;
    
    -- Check if relationship already exists
    IF EXISTS (
        SELECT 1 FROM relationships 
        WHERE (user_id = current_user_id AND partner_id = relationship_record.user_id)
        OR (user_id = relationship_record.user_id AND partner_id = current_user_id)
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Relationship already exists');
    END IF;
    
    -- Update the original relationship
    UPDATE relationships 
    SET 
        partner_id = current_user_id,
        status = 'accepted',
        updated_at = NOW()
    WHERE id = relationship_record.id;
    
    -- Create reciprocal relationship
    INSERT INTO relationships (user_id, partner_id, status, relationship_type)
    VALUES (current_user_id, relationship_record.user_id, 'accepted', relationship_record.relationship_type);
    
    RETURN jsonb_build_object('success', true, 'partner_id', relationship_record.user_id);
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- RPC function to remove partner relationship
CREATE OR REPLACE FUNCTION remove_partner()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id UUID;
    partner_user_id UUID;
    deleted_count INTEGER := 0;
BEGIN
    -- Get current authenticated user
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
    END IF;
    
    -- Find current partner relationship
    SELECT partner_id INTO partner_user_id
    FROM relationships
    WHERE user_id = current_user_id
    AND status = 'accepted'
    AND partner_id IS NOT NULL;
    
    IF partner_user_id IS NULL THEN
        -- Try the reverse relationship
        SELECT user_id INTO partner_user_id
        FROM relationships
        WHERE partner_id = current_user_id
        AND status = 'accepted';
        
        IF partner_user_id IS NULL THEN
            RETURN jsonb_build_object('success', false, 'error', 'No partner relationship found');
        END IF;
    END IF;
    
    -- Delete all relationships between these users
    DELETE FROM relationships
    WHERE (
        (user_id = current_user_id AND partner_id = partner_user_id)
        OR (user_id = partner_user_id AND partner_id = current_user_id)
    );
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    IF deleted_count > 0 THEN
        RETURN jsonb_build_object(
            'success', true, 
            'message', 'Partner relationship removed successfully',
            'removed_partner_id', partner_user_id,
            'deleted_relationships', deleted_count
        );
    ELSE
        RETURN jsonb_build_object('success', false, 'error', 'No relationships found to remove');
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;
```

## Testing Instructions

After running the migration:

1. **App should be running on emulator**
2. **Create a test user account** (via the app's sign-up flow)
3. **Go to Partner Settings** and test invite code creation
4. **Launch second emulator** and repeat partner linking process

The partner sync functionality should now work!