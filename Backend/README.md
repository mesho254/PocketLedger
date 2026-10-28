# PocketLedger — Multi-Module Personal Finance Backend

A multi-module, multi-tenant-isolated Spring Boot 3 application providing a complete personal finance, expense ledger, budgeting, savings goal, and analytics backend connected to **PostgreSQL (`pocketledger_db`)**.

🔗 **📖 [Read the Full Comprehensive Documentation →](COMPREHENSIVE_README.md)** for complete setup, architecture, API reference, and troubleshooting guide.

---

## Quick Start (60 seconds)

### 1. Prerequisites
- Java 21+
- Local PostgreSQL 16/18 (`pocketledger_db` created in pgAdmin 4 on `localhost:5432`, user `postgres`, password `root`)

### 2. Build & Run
```powershell
# Build all modules
.\gradlew.bat clean build

# Run the unified PocketLedger service
.\gradlew.bat :pocketledger-service:bootRun
```

### 3. Access
- **API Base URL:** `http://localhost:8080/api/v1`
- **Swagger UI:** `http://localhost:8080/swagger-ui/index.html`
- **OpenAPI Spec:** `http://localhost:8080/api-docs`

---

## What's Included?

| Module | Purpose | Status |
|--------|---------|--------|
| **auth** | Authentication, JWT Security, User Profile & Base Auditing (`BaseAuditableEntity`) | ✅ Phase 1 |
| **transaction** | Income & Expense Ledger, Filtering & Pagination | ✅ Phase 2 |
| **budget** | Monthly Category Budgets & Spending Threshold Alerts (`SAFE`, `WARNING_80`, `EXCEEDED`) | ✅ Phase 3 |
| **savings** | Target Savings Goals & Atomic Contribution Deposits | ✅ Phase 4 |
| **analytics** | Monthly Financial Summaries, Net Savings Rate & Category Breakdowns | ✅ Phase 5 |
| **pocketledger-service** | Runnable Spring Boot Aggregator Service | ✅ Production Ready |

---

## Key Features

- 🏢 **Strict User Tenancy Isolation** — Isolated data per authenticated user across all modules
- 🔐 **JWT & Refresh Token Authentication** — Stateless Bearer token API security with token blacklisting
- 📊 **Zero Floating-Point Drift** — `BigDecimal` in Java mapped to `NUMERIC(12, 2)` in PostgreSQL
- 🎯 **Monthly Budgets & Alerts** — Real-time spending progress against monthly category limits
- 💰 **Savings Goals & Contributions** — Atomic `@Transactional` goal deposits and completion tracking
- 🔄 **Domain Events** — Event publishing on transactions, budget updates, and savings deposits
- ✅ **Comprehensive Tests** — Validator, service, and controller unit tests across modules
- 🧹 **Code Quality** — Google Java Format & Spotless integration (`./gradlew.bat spotlessApply`)

---

## Create a New Module

```powershell
# Using PowerShell script
.\scripts\new-module.ps1 -ModuleName mymodule

# Or using Gradle
.\gradlew.bat createModule -Pname=mymodule
```

Creates:
- Full Java package structure (`controller`, `service`, `repository`, `entity`, `enums`, `dto`, `mapper`, `exception`, `validation`, `event`)
- Spring Boot & Spotless module `build.gradle`
- Automatic registration in `settings.gradle`

---

## Database Setup (Local PostgreSQL & pgAdmin 4)

```powershell
# Auto-created on startup via Hibernate (spring.jpa.hibernate.ddl-auto=update)
# Or apply migrations manually in pgAdmin Query Tool / psql:

psql -U postgres -d pocketledger_db -f schema/postgresql/001_create_users_and_auth_tables.sql
psql -U postgres -d pocketledger_db -f schema/postgresql/002_create_transactions_table.sql
psql -U postgres -d pocketledger_db -f schema/postgresql/003_create_budgets_table.sql
psql -U postgres -d pocketledger_db -f schema/postgresql/004_create_savings_goals_tables.sql
```

---

## Build & Test

```powershell
# Build all modules
.\gradlew.bat clean build

# Run all tests
.\gradlew.bat test

# Run tests for a specific module
.\gradlew.bat :transaction:test
.\gradlew.bat :budget:test
.\gradlew.bat :savings:test
.\gradlew.bat :analytics:test

# Fix code formatting
.\gradlew.bat spotlessApply
```
