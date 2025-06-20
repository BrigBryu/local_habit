-- Enable Row Level Security and create proper policies using auth.uid()
-- This replaces the permissive development policies with secure ones

-- Enable RLS on all tables
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_events ENABLE ROW LEVEL SECURITY;

-- Enable RLS on relationships table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'relationships') THEN
        ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- Drop existing development policies
DROP POLICY IF EXISTS "Allow all operations on habits for development" ON habits;
DROP POLICY IF EXISTS "Allow all operations on habit_completions for development" ON habit_completions;
DROP POLICY IF EXISTS "Allow all operations on xp_events for development" ON xp_events;
DROP POLICY IF EXISTS "Allow all operations on relationships for development" ON relationships;

-- Create secure RLS policies for habits
CREATE POLICY "Users can manage own habits" ON habits
FOR ALL USING (user_id = auth.uid());

-- Create secure RLS policies for habit_completions
CREATE POLICY "Users can manage own completions" ON habit_completions
FOR ALL USING (user_id = auth.uid());

-- Create secure RLS policies for xp_events
CREATE POLICY "Users can manage own xp_events" ON xp_events
FOR ALL USING (user_id = auth.uid());

-- Create secure RLS policies for relationships (if table exists)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'relationships') THEN
        -- Users can see relationships where they are either user or partner
        CREATE POLICY "Users can see own relationships" ON relationships
        FOR SELECT USING (user_id = auth.uid() OR partner_id = auth.uid());
        
        -- Users can only create relationships where they are the user
        CREATE POLICY "Users can create own relationships" ON relationships
        FOR INSERT WITH CHECK (user_id = auth.uid());
        
        -- Users can delete relationships where they are either user or partner
        CREATE POLICY "Users can delete own relationships" ON relationships
        FOR DELETE USING (user_id = auth.uid() OR partner_id = auth.uid());
    END IF;
END $$;

-- Service role policies for administrative access (if needed)
CREATE POLICY "Service role can manage all habits" ON habits
FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage all completions" ON habit_completions
FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage all xp_events" ON xp_events
FOR ALL USING (auth.role() = 'service_role');

SELECT 'RLS policies created successfully' as status;