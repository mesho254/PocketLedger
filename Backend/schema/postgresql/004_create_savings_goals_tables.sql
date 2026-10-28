-- 004_create_savings_goals_tables.sql
-- Target savings goals and contribution logs tables (PostgreSQL)

CREATE TABLE IF NOT EXISTS public.savings_goals (
    id                 UUID           NOT NULL DEFAULT gen_random_uuid(),
    user_id            UUID           NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title              VARCHAR(100)   NOT NULL,
    target_amount      NUMERIC(12, 2) NOT NULL,
    current_amount     NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    target_date        DATE,
    status             VARCHAR(20)    NOT NULL DEFAULT 'IN_PROGRESS',
    created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    created_by         VARCHAR(255),
    last_modified_by   VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_savings_goals_user ON public.savings_goals(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.savings_contributions (
    id                 UUID           NOT NULL DEFAULT gen_random_uuid(),
    savings_goal_id    UUID           NOT NULL REFERENCES public.savings_goals(id) ON DELETE CASCADE,
    amount             NUMERIC(12, 2) NOT NULL,
    contribution_date  DATE           NOT NULL,
    note               VARCHAR(255),
    created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    created_by         VARCHAR(255),
    last_modified_by   VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_savings_contrib_goal ON public.savings_contributions(savings_goal_id, contribution_date DESC);

