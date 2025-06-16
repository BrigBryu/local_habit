-- Composite index on habits(user_id, updated_at)
-- Optimizes queries for fetching user habits ordered by update time

-- Create composite index for performance optimization
CREATE INDEX IF NOT EXISTS habits_user_updated_idx 
ON habits (user_id, updated_at DESC);

-- Additional useful indexes for habit queries:
CREATE INDEX IF NOT EXISTS habits_user_status_idx 
ON habits (user_id, status);

CREATE INDEX IF NOT EXISTS habits_updated_at_idx 
ON habits (updated_at DESC);