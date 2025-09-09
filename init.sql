-- PostgreSQL initialization script for Kortix/Suna
-- This script creates the necessary database schema to replace Supabase
-- It combines all the essential migrations from the Supabase migrations

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth schema for user management
CREATE SCHEMA IF NOT EXISTS auth;

-- Create basic auth.users table to replace Supabase auth
CREATE TABLE IF NOT EXISTS auth.users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    email text UNIQUE NOT NULL,
    encrypted_password text,
    email_confirmed_at timestamptz,
    invited_at timestamptz,
    confirmation_token text,
    confirmation_sent_at timestamptz,
    recovery_token text,
    recovery_sent_at timestamptz,
    email_change_token_new text,
    email_change text,
    email_change_sent_at timestamptz,
    last_sign_in_at timestamptz,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    phone text DEFAULT NULL,
    phone_confirmed_at timestamptz,
    phone_change text DEFAULT '',
    phone_change_token text DEFAULT '',
    phone_change_sent_at timestamptz,
    confirmed_at timestamptz GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current text DEFAULT '',
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamptz,
    reauthentication_token text DEFAULT '',
    reauthentication_sent_at timestamptz,
    is_sso_user boolean NOT NULL DEFAULT false,
    deleted_at timestamptz,
    is_anonymous boolean NOT NULL DEFAULT false
);

-- Create public schema tables for the application
CREATE SCHEMA IF NOT EXISTS public;

-- Accounts table (from basejump)
CREATE TABLE IF NOT EXISTS public.accounts (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text,
    slug text UNIQUE,
    personal_account boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid,
    updated_by uuid,
    primary_owner_user_id uuid REFERENCES auth.users(id)
);

-- Account users (team members)
CREATE TABLE IF NOT EXISTS public.account_user (
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    account_role text NOT NULL DEFAULT 'member',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    PRIMARY KEY (user_id, account_id)
);

-- Agents table
CREATE TABLE IF NOT EXISTS public.agents (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    name text NOT NULL,
    instructions text,
    system_prompt text,
    description text,
    config jsonb DEFAULT '{}',
    metadata jsonb DEFAULT '{}',
    avatar_url text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id),
    is_default boolean DEFAULT false,
    version integer DEFAULT 1,
    is_template boolean DEFAULT false,
    is_published boolean DEFAULT false,
    template_category text,
    profile_pic_url text
);

-- Threads table
CREATE TABLE IF NOT EXISTS public.threads (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    agent_id uuid REFERENCES public.agents(id),
    title text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id),
    metadata jsonb DEFAULT '{}',
    agent_config jsonb DEFAULT '{}'
);

-- Messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    thread_id uuid REFERENCES public.threads(id) ON DELETE CASCADE,
    role text NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    metadata jsonb DEFAULT '{}',
    tool_calls jsonb DEFAULT '[]',
    tool_call_id text,
    name text
);

-- Agent runs table (for tracking agent executions)
CREATE TABLE IF NOT EXISTS public.agent_runs (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    thread_id uuid REFERENCES public.threads(id) ON DELETE CASCADE,
    agent_id uuid REFERENCES public.agents(id),
    status text NOT NULL DEFAULT 'running',
    started_at timestamptz DEFAULT now(),
    completed_at timestamptz,
    error_message text,
    metadata jsonb DEFAULT '{}',
    run_metadata jsonb DEFAULT '{}'
);

-- Files table (for file uploads and knowledge base)
CREATE TABLE IF NOT EXISTS public.files (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    name text NOT NULL,
    file_path text,
    file_size integer,
    mime_type text,
    upload_completed boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    metadata jsonb DEFAULT '{}'
);

-- Agent knowledge base files
CREATE TABLE IF NOT EXISTS public.agent_kb_files (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id uuid REFERENCES public.agents(id) ON DELETE CASCADE,
    file_id uuid REFERENCES public.files(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    UNIQUE(agent_id, file_id)
);

-- Credentials table (for secure credential storage)
CREATE TABLE IF NOT EXISTS public.credentials (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    name text NOT NULL,
    encrypted_config text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id)
);

-- Agent triggers (for automation)
CREATE TABLE IF NOT EXISTS public.agent_triggers (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id uuid REFERENCES public.agents(id) ON DELETE CASCADE,
    trigger_type text NOT NULL,
    trigger_config jsonb DEFAULT '{}',
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id)
);

-- User roles and permissions
CREATE TABLE IF NOT EXISTS public.user_roles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    role text NOT NULL DEFAULT 'user',
    granted_at timestamptz DEFAULT now(),
    granted_by uuid REFERENCES auth.users(id),
    UNIQUE(user_id)
);

-- Credit system for usage tracking
CREATE TABLE IF NOT EXISTS public.credit_accounts (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE UNIQUE,
    credits_balance integer DEFAULT 0,
    tier text DEFAULT 'free',
    last_grant_date timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Billing cycles tracking
CREATE TABLE IF NOT EXISTS public.billing_cycles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    cycle_start timestamptz NOT NULL,
    cycle_end timestamptz NOT NULL,
    usage_count integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- API keys for external access
CREATE TABLE IF NOT EXISTS public.api_keys (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    name text NOT NULL,
    key_hash text NOT NULL,
    last_used_at timestamptz,
    created_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    is_active boolean DEFAULT true
);

-- Google OAuth tokens (for integrations)
CREATE TABLE IF NOT EXISTS public.google_oauth_tokens (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    access_token text NOT NULL,
    refresh_token text,
    expires_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(user_id)
);

-- Admin actions log
CREATE TABLE IF NOT EXISTS public.admin_actions_log (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_user_id uuid REFERENCES auth.users(id),
    action text NOT NULL,
    target_user_id uuid REFERENCES auth.users(id),
    details jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_accounts_slug ON public.accounts(slug);
CREATE INDEX IF NOT EXISTS idx_agents_account_id ON public.agents(account_id);
CREATE INDEX IF NOT EXISTS idx_threads_account_id ON public.threads(account_id);
CREATE INDEX IF NOT EXISTS idx_threads_agent_id ON public.threads(agent_id);
CREATE INDEX IF NOT EXISTS idx_messages_thread_id ON public.messages(thread_id);
CREATE INDEX IF NOT EXISTS idx_agent_runs_thread_id ON public.agent_runs(thread_id);
CREATE INDEX IF NOT EXISTS idx_files_account_id ON public.files(account_id);
CREATE INDEX IF NOT EXISTS idx_credentials_account_id ON public.credentials(account_id);
CREATE INDEX IF NOT EXISTS idx_agent_triggers_agent_id ON public.agent_triggers(agent_id);
CREATE INDEX IF NOT EXISTS idx_credit_accounts_account_id ON public.credit_accounts(account_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_account_id ON public.api_keys(account_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER set_accounts_updated_at BEFORE UPDATE ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_agents_updated_at BEFORE UPDATE ON public.agents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_threads_updated_at BEFORE UPDATE ON public.threads FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_messages_updated_at BEFORE UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_files_updated_at BEFORE UPDATE ON public.files FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_credentials_updated_at BEFORE UPDATE ON public.credentials FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_credit_accounts_updated_at BEFORE UPDATE ON public.credit_accounts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Insert default admin user
-- Password: 'SunaAdmin123!' (hashed with bcrypt)
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, is_super_admin) 
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'admin@suna.local',
    '$2a$10$rR7vK8k/W9ZvH4jGxJKzOePQx6S5QmAk3yRtcFJx8xJKGJwRj7tCu',  -- SunaAdmin123!
    now(),
    now(),
    now(),
    '{"role": "admin", "full_name": "Suna Administrator"}'::jsonb,
    true
) ON CONFLICT (email) DO NOTHING;

-- Create default account for admin
INSERT INTO public.accounts (id, name, slug, personal_account, primary_owner_user_id, created_at, updated_at)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'Admin Account',
    'admin-account',
    true,
    '00000000-0000-0000-0000-000000000001'::uuid,
    now(),
    now()
) ON CONFLICT (slug) DO NOTHING;

-- Add admin to their account
INSERT INTO public.account_user (user_id, account_id, account_role)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'owner'
) ON CONFLICT DO NOTHING;

-- Set admin role
INSERT INTO public.user_roles (user_id, role)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'admin'
) ON CONFLICT (user_id) DO NOTHING;

-- Create default credit account
INSERT INTO public.credit_accounts (account_id, credits_balance, tier)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    1000000,  -- Admin gets 1M credits
    'admin'
) ON CONFLICT (account_id) DO NOTHING;

-- Additional tables for complete functionality

-- Integrations table (MCP, Composio, etc.)
CREATE TABLE IF NOT EXISTS public.integrations (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    integration_type text NOT NULL, -- 'mcp', 'composio', 'google', etc.
    name text NOT NULL,
    config jsonb DEFAULT '{}',
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id)
);

-- Usage logs for analytics and billing
CREATE TABLE IF NOT EXISTS public.usage_logs (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    agent_id uuid REFERENCES public.agents(id),
    thread_id uuid REFERENCES public.threads(id),
    action_type text NOT NULL, -- 'message', 'tool_call', 'file_upload', etc.
    tokens_used integer DEFAULT 0,
    credits_used integer DEFAULT 0,
    cost decimal(10,6) DEFAULT 0,
    model_name text,
    provider text,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now()
);

-- Webhooks configuration
CREATE TABLE IF NOT EXISTS public.webhooks (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE,
    name text NOT NULL,
    url text NOT NULL,
    events text[] DEFAULT '{}', -- Array of event types
    secret text,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id)
);

-- Webhook delivery logs
CREATE TABLE IF NOT EXISTS public.webhook_deliveries (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    webhook_id uuid REFERENCES public.webhooks(id) ON DELETE CASCADE,
    event_type text NOT NULL,
    payload jsonb DEFAULT '{}',
    response_status integer,
    response_body text,
    delivered_at timestamptz,
    attempts integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- System settings
CREATE TABLE IF NOT EXISTS public.system_settings (
    key text PRIMARY KEY,
    value jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Insert default system settings
INSERT INTO public.system_settings (key, value) VALUES
    ('maintenance_mode', '{"enabled": false, "message": "System under maintenance"}'),
    ('registration_enabled', '{"enabled": true}'),
    ('default_credits', '{"free_tier": 1000, "pro_tier": 10000}'),
    ('rate_limits', '{"messages_per_minute": 60, "api_calls_per_minute": 100}')
ON CONFLICT (key) DO NOTHING;

-- Create default Suna agent
INSERT INTO public.agents (id, account_id, name, instructions, system_prompt, description, is_default, created_by, config)
VALUES (
    '00000000-0000-0000-0000-000000000002'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'Suna',
    'You are Suna, a powerful AI assistant that can help with research, analysis, file management, web automation, and many other tasks. Always be helpful, accurate, and professional.',
    'You are Suna, an advanced AI assistant created by Kortix. You have access to many tools and capabilities including web browsing, file operations, code execution, and integrations with external services. Help users accomplish their tasks efficiently and accurately.',
    'Suna is the flagship generalist AI worker that demonstrates the full capabilities of the Kortix platform.',
    true,
    '00000000-0000-0000-0000-000000000001'::uuid,
    '{"model": "gpt-4", "temperature": 0.7, "max_tokens": 2000}'::jsonb
) ON CONFLICT DO NOTHING;

-- Add more indexes for performance
CREATE INDEX IF NOT EXISTS idx_integrations_account_id ON public.integrations(account_id);
CREATE INDEX IF NOT EXISTS idx_integrations_type ON public.integrations(integration_type);
CREATE INDEX IF NOT EXISTS idx_usage_logs_account_id ON public.usage_logs(account_id);
CREATE INDEX IF NOT EXISTS idx_usage_logs_created_at ON public.usage_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_webhooks_account_id ON public.webhooks(account_id);
CREATE INDEX IF NOT EXISTS idx_webhook_deliveries_webhook_id ON public.webhook_deliveries(webhook_id);
CREATE INDEX IF NOT EXISTS idx_auth_users_email ON auth.users(email);

-- Add updated_at triggers for new tables
CREATE TRIGGER set_integrations_updated_at BEFORE UPDATE ON public.integrations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_webhooks_updated_at BEFORE UPDATE ON public.webhooks FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_system_settings_updated_at BEFORE UPDATE ON public.system_settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Grant necessary permissions to application user
GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA auth TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO postgres;