# PocketLedger — PostgreSQL Database Migrations

This directory contains PostgreSQL migration scripts for the **PocketLedger** personal finance platform targeting `pocketledger_db`.

## Running Migrations

In local development, `pocketledger-service` uses Hibernate's `spring.jpa.hibernate.ddl-auto=update` to automatically create and synchronize all tables in the `public` schema of `pocketledger_db` on startup.

For manual setup in **pgAdmin 4** (Query Tool) or via `psql`, execute these scripts in numerical order:

```bash
psql -h localhost -p 5432 -U postgres -d pocketledger_db -f schema/postgresql/001_create_users_and_auth_tables.sql
psql -h localhost -p 5432 -U postgres -d pocketledger_db -f schema/postgresql/002_create_transactions_table.sql
psql -h localhost -p 5432 -U postgres -d pocketledger_db -f schema/postgresql/003_create_budgets_table.sql
psql -h localhost -p 5432 -U postgres -d pocketledger_db -f schema/postgresql/004_create_savings_goals_tables.sql
```

## Tables Created in `pocketledger_db.public`

| Script | Tables | Module |
| :--- | :--- | :--- |
| `001_create_users_and_auth_tables.sql` | `users`, `refresh_tokens` | `:auth` |
| `002_create_transactions_table.sql` | `transactions` | `:transaction` |
| `003_create_budgets_table.sql` | `budgets` | `:budget` |
| `004_create_savings_goals_tables.sql` | `savings_goals`, `savings_contributions` | `:savings` |

