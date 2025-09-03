-- =====================================================
-- OTP TABLE SCHEMA AND SETUP
-- =====================================================
-- Execute this in Supabase SQL Editor to create the OTP table and setup

-- Drop existing table if it exists (be careful in production!)
DROP TABLE IF EXISTS public.otp CASCADE;

-- Create the OTP table
CREATE TABLE public.otp (
    id_otp UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    code_hash TEXT NOT NULL,
    tag TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    used_by_id_user UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    burned_at TIMESTAMPTZ
);

-- Create indexes for better performance
CREATE INDEX idx_otp_code_hash ON public.otp(code_hash);
CREATE INDEX idx_otp_id_user ON public.otp(id_user);
CREATE INDEX idx_otp_expires_at ON public.otp(expires_at);
CREATE INDEX idx_otp_created_at ON public.otp(created_at);
CREATE INDEX idx_otp_tag ON public.otp(tag) WHERE tag IS NOT NULL;
CREATE INDEX idx_otp_used_at ON public.otp(used_at) WHERE used_at IS NOT NULL;
CREATE INDEX idx_otp_burned_at ON public.otp(burned_at) WHERE burned_at IS NOT NULL;

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_otp_updated_at
    BEFORE UPDATE ON public.otp
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE public.otp ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own OTPs" ON public.otp;
DROP POLICY IF EXISTS "Users can insert their own OTPs" ON public.otp;
DROP POLICY IF EXISTS "Users can update their own OTPs" ON public.otp;
DROP POLICY IF EXISTS "Users can delete their own OTPs" ON public.otp;
DROP POLICY IF EXISTS "Service role can manage all OTPs" ON public.otp;

-- Create RLS policies
-- Users can only see their own OTPs
CREATE POLICY "Users can view their own OTPs" ON public.otp
    FOR SELECT USING (auth.uid() = id_user);

-- Users can insert their own OTPs
CREATE POLICY "Users can insert their own OTPs" ON public.otp
    FOR INSERT WITH CHECK (auth.uid() = id_user);

-- Users can update their own OTPs
CREATE POLICY "Users can update their own OTPs" ON public.otp
    FOR UPDATE USING (auth.uid() = id_user);

-- Users can delete their own OTPs
CREATE POLICY "Users can delete their own OTPs" ON public.otp
    FOR DELETE USING (auth.uid() = id_user);

-- Service role can manage all OTPs (for edge functions)
CREATE POLICY "Service role can manage all OTPs" ON public.otp
    FOR ALL USING (auth.role() = 'service_role');

-- Grant permissions to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON public.otp TO authenticated;

-- Grant permissions to service role (for edge functions)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.otp TO service_role;

-- Grant usage on sequence (if needed)
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;
