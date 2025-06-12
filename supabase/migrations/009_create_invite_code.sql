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

create policy "Users can delete own invite codes" on public.invite_codes
  for delete using (auth.uid() = user_id);

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
exception
  when others then
    raise exception 'Error creating invite code: %', sqlerrm;
end;
$$;

-- Allow callers to execute the function
grant execute on function public.create_invite_code() to anon, authenticated;

-- Create index for performance
create index if not exists idx_invite_codes_user_id on public.invite_codes(user_id);
create index if not exists idx_invite_codes_expires_at on public.invite_codes(expires_at);