-- =====================================================
-- OTP MANAGEMENT FUNCTIONS
-- =====================================================
-- Execute this in Supabase SQL Editor to create all OTP functions

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS public.otp_create(UUID, TEXT, INTEGER, INTEGER, BOOLEAN);
DROP FUNCTION IF EXISTS public.otp_verify(TEXT, UUID, TEXT, BOOLEAN, UUID);
DROP FUNCTION IF EXISTS public.otp_burn(UUID, UUID);
DROP FUNCTION IF EXISTS public.otp_gc(TIMESTAMPTZ);

-- =====================================================
-- FUNCTION: otp_create
-- =====================================================
-- Creates a new OTP with specified parameters
CREATE OR REPLACE FUNCTION public.otp_create(
    p_id_user UUID DEFAULT NULL,
    p_tag TEXT DEFAULT NULL,
    p_ttl_seconds INTEGER DEFAULT 300,
    p_length INTEGER DEFAULT 6,
    p_numeric_only BOOLEAN DEFAULT TRUE
)
RETURNS TABLE (
    id_otp UUID,
    id_user UUID,
    code TEXT,
    code_hash TEXT,
    tag TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    used_at TIMESTAMPTZ,
    used_by_id_user UUID,
    burned_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code TEXT;
    v_code_hash TEXT;
    v_expires_at TIMESTAMPTZ;
    v_result RECORD;
    v_attempts INTEGER := 0;
    v_max_attempts INTEGER := 10;
BEGIN
    -- Validate input parameters
    IF p_length < 4 OR p_length > 10 THEN
        RAISE EXCEPTION 'OTP length must be between 4 and 10 characters';
    END IF;
    
    IF p_ttl_seconds < 60 OR p_ttl_seconds > 86400 THEN
        RAISE EXCEPTION 'TTL must be between 60 seconds and 24 hours';
    END IF;
    
    -- Generate unique code (retry if collision)
    LOOP
        v_attempts := v_attempts + 1;
        
        IF v_attempts > v_max_attempts THEN
            RAISE EXCEPTION 'Failed to generate unique OTP code after % attempts', v_max_attempts;
        END IF;
        
        -- Generate code based on parameters
        IF p_numeric_only THEN
            -- Generate numeric code
            v_code := LPAD(FLOOR(RANDOM() * POWER(10, p_length))::TEXT, p_length, '0');
        ELSE
            -- Generate alphanumeric code (uppercase letters and numbers)
            v_code := '';
            FOR i IN 1..p_length LOOP
                IF RANDOM() < 0.5 THEN
                    -- Add a number
                    v_code := v_code || FLOOR(RANDOM() * 10)::TEXT;
                ELSE
                    -- Add a letter
                    v_code := v_code || CHR(65 + FLOOR(RANDOM() * 26)::INTEGER);
                END IF;
            END LOOP;
        END IF;
        
        -- Hash the code
        v_code_hash := ENCODE(DIGEST(v_code, 'sha256'), 'hex');
        
        -- Check if this hash already exists and is still valid
        IF NOT EXISTS (
            SELECT 1 FROM public.otp 
            WHERE public.otp.code_hash = v_code_hash 
            AND public.otp.burned_at IS NULL 
            AND public.otp.used_at IS NULL 
            AND public.otp.expires_at > NOW()
        ) THEN
            EXIT; -- Unique code found
        END IF;
    END LOOP;
    
    -- Calculate expiration time
    v_expires_at := NOW() + (p_ttl_seconds || ' seconds')::INTERVAL;
    
    -- Insert the OTP
    INSERT INTO public.otp (
        id_user,
        code,
        code_hash,
        tag,
        created_at,
        updated_at,
        expires_at
    ) VALUES (
        p_id_user,
        v_code,
        v_code_hash,
        p_tag,
        NOW(),
        NOW(),
        v_expires_at
    ) RETURNING * INTO v_result;
    
    -- Return the created OTP
    RETURN QUERY SELECT 
        v_result.id_otp,
        v_result.id_user,
        v_result.code,
        v_result.code_hash,
        v_result.tag,
        v_result.created_at,
        v_result.updated_at,
        v_result.expires_at,
        v_result.used_at,
        v_result.used_by_id_user,
        v_result.burned_at;
END;
$$;

-- =====================================================
-- FUNCTION: otp_verify
-- =====================================================
-- Verifies an OTP code and optionally marks it as used
CREATE OR REPLACE FUNCTION public.otp_verify(
    p_code TEXT,
    p_id_user UUID DEFAULT NULL,
    p_tag TEXT DEFAULT NULL,
    p_mark_used BOOLEAN DEFAULT TRUE,
    p_used_by UUID DEFAULT NULL
)
RETURNS TABLE (
    id_otp UUID,
    id_user UUID,
    code TEXT,
    code_hash TEXT,
    tag TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    used_at TIMESTAMPTZ,
    used_by_id_user UUID,
    burned_at TIMESTAMPTZ,
    is_valid BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_otp RECORD;
    v_code_hash TEXT;
    v_is_valid BOOLEAN := FALSE;
BEGIN
    -- Validate input
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) = 0 THEN
        RAISE EXCEPTION 'OTP code cannot be empty';
    END IF;
    
    -- Hash the provided code
    v_code_hash := ENCODE(DIGEST(TRIM(p_code), 'sha256'), 'hex');
    
    -- Find the OTP
    SELECT * INTO v_otp
    FROM public.otp
    WHERE public.otp.code_hash = v_code_hash
    AND (p_id_user IS NULL OR public.otp.id_user = p_id_user)
    AND (p_tag IS NULL OR public.otp.tag = p_tag)
    AND public.otp.burned_at IS NULL
    AND public.otp.used_at IS NULL
    AND public.otp.expires_at > NOW()
    ORDER BY public.otp.created_at DESC
    LIMIT 1;
    
    -- Check if OTP was found and is valid
    IF v_otp.id_otp IS NOT NULL THEN
        v_is_valid := TRUE;
        
        -- Mark as used if requested
        IF p_mark_used THEN
            UPDATE public.otp
            SET 
                used_at = NOW(),
                used_by_id_user = p_used_by,
                updated_at = NOW()
            WHERE public.otp.id_otp = v_otp.id_otp;
            
            -- Update the record
            v_otp.used_at := NOW();
            v_otp.used_by_id_user := p_used_by;
            v_otp.updated_at := NOW();
        END IF;
    END IF;
    
    -- Return the result
    RETURN QUERY SELECT 
        v_otp.id_otp,
        v_otp.id_user,
        v_otp.code,
        v_otp.code_hash,
        v_otp.tag,
        v_otp.created_at,
        v_otp.updated_at,
        v_otp.expires_at,
        v_otp.used_at,
        v_otp.used_by_id_user,
        v_otp.burned_at,
        v_is_valid;
END;
$$;

-- =====================================================
-- FUNCTION: otp_burn
-- =====================================================
-- Burns (invalidates) an OTP permanently
CREATE OR REPLACE FUNCTION public.otp_burn(
    p_id_otp UUID,
    p_id_user UUID DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    -- Validate input
    IF p_id_otp IS NULL THEN
        RAISE EXCEPTION 'OTP ID cannot be null';
    END IF;
    
    -- Update the OTP to mark it as burned
    UPDATE public.otp
    SET 
        burned_at = NOW(),
        updated_at = NOW()
    WHERE public.otp.id_otp = p_id_otp
    AND (p_id_user IS NULL OR public.otp.id_user = p_id_user)
    AND public.otp.burned_at IS NULL;
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    
    RETURN v_updated_count > 0;
END;
$$;

-- =====================================================
-- FUNCTION: otp_gc
-- =====================================================
-- Garbage collection: marks expired OTPs as burned
CREATE OR REPLACE FUNCTION public.otp_gc(
    p_before TIMESTAMPTZ DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_before TIMESTAMPTZ;
    v_burned_count INTEGER;
BEGIN
    -- Use provided time or default to now
    v_before := COALESCE(p_before, NOW());
    
    -- Mark expired OTPs as burned
    UPDATE public.otp
    SET 
        burned_at = NOW(),
        updated_at = NOW()
    WHERE public.otp.expires_at <= v_before
    AND public.otp.burned_at IS NULL;
    
    GET DIAGNOSTICS v_burned_count = ROW_COUNT;
    
    RETURN v_burned_count;
END;
$$;

-- =====================================================
-- FUNCTION: otp_get_metadata
-- =====================================================
-- Gets OTP metadata without sensitive data (code/hash)
CREATE OR REPLACE FUNCTION public.otp_get_metadata(
    p_id_otp UUID
)
RETURNS TABLE (
    id_otp UUID,
    id_user UUID,
    tag TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    used_at TIMESTAMPTZ,
    used_by_id_user UUID,
    burned_at TIMESTAMPTZ,
    is_expired BOOLEAN,
    is_used BOOLEAN,
    is_burned BOOLEAN,
    is_valid BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_otp RECORD;
BEGIN
    -- Validate input
    IF p_id_otp IS NULL THEN
        RAISE EXCEPTION 'OTP ID cannot be null';
    END IF;
    
    -- Get the OTP metadata
    SELECT 
        id_otp,
        id_user,
        tag,
        created_at,
        updated_at,
        expires_at,
        used_at,
        used_by_id_user,
        burned_at,
        (expires_at <= NOW()) as is_expired,
        (used_at IS NOT NULL) as is_used,
        (burned_at IS NOT NULL) as is_burned,
        (expires_at > NOW() AND used_at IS NULL AND burned_at IS NULL) as is_valid
    INTO v_otp
    FROM public.otp
    WHERE public.otp.id_otp = p_id_otp;
    
    -- Return the result
    RETURN QUERY SELECT 
        v_otp.id_otp,
        v_otp.id_user,
        v_otp.tag,
        v_otp.created_at,
        v_otp.updated_at,
        v_otp.expires_at,
        v_otp.used_at,
        v_otp.used_by_id_user,
        v_otp.burned_at,
        v_otp.is_expired,
        v_otp.is_used,
        v_otp.is_burned,
        v_otp.is_valid;
END;
$$;

-- =====================================================
-- FUNCTION: otp_list_user_otps
-- =====================================================
-- Lists all OTPs for a specific user (metadata only)
CREATE OR REPLACE FUNCTION public.otp_list_user_otps(
    p_id_user UUID,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id_otp UUID,
    id_user UUID,
    tag TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    used_at TIMESTAMPTZ,
    used_by_id_user UUID,
    burned_at TIMESTAMPTZ,
    is_expired BOOLEAN,
    is_used BOOLEAN,
    is_burned BOOLEAN,
    is_valid BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Validate input
    IF p_id_user IS NULL THEN
        RAISE EXCEPTION 'User ID cannot be null';
    END IF;
    
    IF p_limit < 1 OR p_limit > 100 THEN
        RAISE EXCEPTION 'Limit must be between 1 and 100';
    END IF;
    
    IF p_offset < 0 THEN
        RAISE EXCEPTION 'Offset cannot be negative';
    END IF;
    
    -- Return user's OTPs
    RETURN QUERY 
    SELECT 
        o.id_otp,
        o.id_user,
        o.tag,
        o.created_at,
        o.updated_at,
        o.expires_at,
        o.used_at,
        o.used_by_id_user,
        o.burned_at,
        (o.expires_at <= NOW()) as is_expired,
        (o.used_at IS NOT NULL) as is_used,
        (o.burned_at IS NOT NULL) as is_burned,
        (o.expires_at > NOW() AND o.used_at IS NULL AND o.burned_at IS NULL) as is_valid
    FROM public.otp o
    WHERE o.id_user = p_id_user
    ORDER BY o.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

-- Grant permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.otp_create(UUID, TEXT, INTEGER, INTEGER, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.otp_verify(TEXT, UUID, TEXT, BOOLEAN, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.otp_burn(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.otp_gc(TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION public.otp_get_metadata(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.otp_list_user_otps(UUID, INTEGER, INTEGER) TO authenticated;

-- Grant permissions to service role (for edge functions)
GRANT EXECUTE ON FUNCTION public.otp_create(UUID, TEXT, INTEGER, INTEGER, BOOLEAN) TO service_role;
GRANT EXECUTE ON FUNCTION public.otp_verify(TEXT, UUID, TEXT, BOOLEAN, UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.otp_burn(UUID, UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.otp_gc(TIMESTAMPTZ) TO service_role;
GRANT EXECUTE ON FUNCTION public.otp_get_metadata(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.otp_list_user_otps(UUID, INTEGER, INTEGER) TO service_role;
