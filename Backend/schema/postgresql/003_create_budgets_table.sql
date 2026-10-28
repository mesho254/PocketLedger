-- 003_create_budgets_table.sql
-- Monthly category budget limits and threshold tracking table (PostgreSQL)

CREATE TABLE IF NOT EXISTS public.budgets (
    id                 UUID           NOT NULL DEFAULT gen_random_uuid(),
    user_id            UUID           NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    category           VARCHAR(50)    NOT NULL,
    monthly_limit      NUMERIC(12, 2) NOT NULL,
    budget_month       INTEGER        NOT NULL CHECK (budget_month BETWEEN 1 AND 12),
    budget_year        INTEGER        NOT NULL CHECK (budget_year >= 2000),
    created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    created_by         VARCHAR(255),
    last_modified_by   VARCHAR(255),
    PRIMARY KEY (id),
    CONSTRAINT uk_user_year_month_category UNIQUE (user_id, budget_year, budget_month, category)
);

CREATE INDEX IF NOT EXISTS idx_budgets_user_period ON public.budgets(user_id, budget_year, budget_month);

