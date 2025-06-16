-- Enforce self-partnership CHECK constraint
-- Prevents users from partnering with themselves

-- Add CHECK constraint to relationships table
ALTER TABLE relationships 
ADD CONSTRAINT check_no_self_partnership 
CHECK (user_id_1 != user_id_2);

-- Alternative constraint names for different relationship column structures:
-- If using user_id and partner_id columns:
-- ALTER TABLE relationships 
-- ADD CONSTRAINT check_no_self_partnership 
-- CHECK (user_id != partner_id);