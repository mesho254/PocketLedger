-- 002_create_transactions_table.sql
-- Personal finance income and expense transactions table (PostgreSQL)

CREATE TABLE IF NOT EXISTS public.transactions (
    id                 UUID           NOT NULL DEFAULT gen_random_uuid(),
    user_id            UUID           NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    amount             NUMERIC(12, 2) NOT NULL,
    type               VARCHAR(10)    NOT NULL CHECK (type IN ('INCOME', 'EXPENSE')),
    category           VARCHAR(50)    NOT NULL,
    transaction_date   DATE           NOT NULL,
    description        VARCHAR(255),
    created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    created_by         VARCHAR(255),
    last_modified_by   VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_tx_user_date ON public.transactions(user_id, transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_tx_user_type ON public.transactions(user_id, type);

