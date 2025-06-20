-- Migrate habits table to reference auth.users instead of custom accounts table
-- WARNING: This will break existing data if accounts.id != auth.users.id

-- Step 1: Drop existing foreign key constraint
ALTER TABLE habits DROP CONSTRAINT IF EXISTS habits_user_id_fkey;

-- Step 2: Add new foreign key constraint to auth.users
ALTER TABLE habits ADD CONSTRAINT habits_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Step 3: Also update related tables to reference auth.users
ALTER TABLE habit_completions DROP CONSTRAINT IF EXISTS habit_completions_user_id_fkey;
ALTER TABLE habit_completions ADD CONSTRAINT habit_completions_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE xp_events DROP CONSTRAINT IF EXISTS xp_events_user_id_fkey;
ALTER TABLE xp_events ADD CONSTRAINT xp_events_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Step 4: Update relationships table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'relationships') THEN
        ALTER TABLE relationships DROP CONSTRAINT IF EXISTS relationships_user_id_fkey;
        ALTER TABLE relationships ADD CONSTRAINT relationships_user_id_fkey 
            FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
            
        ALTER TABLE relationships DROP CONSTRAINT IF EXISTS relationships_partner_id_fkey;
        ALTER TABLE relationships ADD CONSTRAINT relationships_partner_id_fkey 
            FOREIGN KEY (partner_id) REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
END $$;

SELECT 'Habits foreign keys migrated to auth.users successfully' as status;