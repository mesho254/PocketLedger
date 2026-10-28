-- 001_create_users_and_auth_tables.sql
-- Core authentication and user tables for PocketLedger (PostgreSQL)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS public.users (
    id                 UUID          NOT NULL DEFAULT gen_random_uuid(),
    email              VARCHAR(255)  NOT NULL UNIQUE,
    password_hash      VARCHAR(255)  NOT NULL,
    full_name          VARCHAR(255)  NOT NULL,
    currency           VARCHAR(10)   NOT NULL DEFAULT 'USD',
    role               VARCHAR(20)   NOT NULL DEFAULT 'USER',
    created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    created_by         VARCHAR(255),
    last_modified_by   VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.refresh_tokens (
    id                 UUID          NOT NULL DEFAULT gen_random_uuid(),
    user_id            UUID          NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    token_hash         VARCHAR(128)  NOT NULL UNIQUE,
    expiry_date        TIMESTAMPTZ   NOT NULL,
    revoked            BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    created_by         VARCHAR(255),
    last_modified_by   VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON public.refresh_tokens(user_id);

