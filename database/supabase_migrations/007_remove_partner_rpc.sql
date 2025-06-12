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