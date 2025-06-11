-- RPC function to generate and link partner by invite code
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