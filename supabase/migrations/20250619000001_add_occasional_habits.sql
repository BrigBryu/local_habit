-- Add support for Interval and Weekly habits
-- This migration adds the necessary fields to support IntervalHabit and WeeklyHabit types

-- Add new fields to habits table for occasional habits
ALTER TABLE habits 
ADD COLUMN IF NOT EXISTS interval_days INTEGER,
ADD COLUMN IF NOT EXISTS weekday_mask SMALLINT,
ADD COLUMN IF NOT EXISTS last_completion_date DATE;

-- Add comments for clarity
COMMENT ON COLUMN habits.interval_days IS 'Number of days between completions for interval habits (null for non-interval habits)';
COMMENT ON COLUMN habits.weekday_mask IS '7-bit mask for weekly habits: bit 0=Sunday, bit 1=Monday, etc. (null for non-weekly habits)';
COMMENT ON COLUMN habits.last_completion_date IS 'Date of last completion for interval/weekly habits (null for other types)';

-- Create index for performance on last_completion_date
CREATE INDEX IF NOT EXISTS idx_habits_last_completion_date ON habits(last_completion_date);

-- Add constraint to ensure interval_days is positive when set
ALTER TABLE habits 
ADD CONSTRAINT chk_interval_days_positive 
CHECK (interval_days IS NULL OR interval_days > 0);

-- Add constraint to ensure weekday_mask is valid 7-bit value when set (0-127)
ALTER TABLE habits 
ADD CONSTRAINT chk_weekday_mask_valid 
CHECK (weekday_mask IS NULL OR (weekday_mask >= 0 AND weekday_mask <= 127));

-- Update schema version comment
COMMENT ON TABLE habits IS 'Habits table with support for basic, avoidance, bundle, stack, interval, and weekly habit types';

SELECT 'Occasional habits fields added successfully' as status;