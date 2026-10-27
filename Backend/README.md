# PocketLedger REST API

Enterprise personal finance & budgeting backend built with **Spring Boot 3.3.5 (Java 21)** and **PostgreSQL 16**.

---

## Architecture Highlights
- **Stateless Authentication**: Spring Security 6 + JJWT 0.12 (HMAC-SHA256) Bearer tokens.
- **Tenancy Data Isolation**: Every transaction, budget, and savings goal query enforces strict `user_id` scoping at the JPA layer.
- **Financial Math Safety**: All currency values use `BigDecimal` in Java and `NUMERIC(12, 2)` in PostgreSQL to eliminate floating-point precision loss.
- **Interactive OpenAPI/Swagger**: Full OpenAPI 3.0 specification available at `/swagger-ui/index.html` with Bearer auth support.

---

## Quickstart

### 1. Start PostgreSQL
```bash
docker compose up -d
```
*(Runs PostgreSQL 16 Alpine on port `5433`, database: `pocketledger_db`)*

### 2. Build & Run Tests
```bash
cd Backend
./mvnw clean test
```

### 3. Run the Application
```bash
./mvnw spring-boot:run
# OR run the packaged jar
java -jar target/pocketledger-api-0.0.1-SNAPSHOT.jar
```
Application starts on `http://localhost:8080`.

---

## API Documentation & Endpoints

Interactive Swagger UI: **`http://localhost:8080/swagger-ui/index.html`**  
OpenAPI JSON Spec: **`http://localhost:8080/api-docs`**

### Authentication
* `POST /api/v1/auth/register` — Register a new user
* `POST /api/v1/auth/login` — Login and receive JWT access token
* `GET /api/v1/auth/me` — Retrieve current authenticated user profile

### Transactions
* `POST /api/v1/transactions` — Record income or expense
* `GET /api/v1/transactions` — Filter transactions by `startDate`, `endDate`, `type` (`INCOME`/`EXPENSE`), `category`, with pagination
* `GET /api/v1/transactions/{id}` — Get single transaction details
* `PUT /api/v1/transactions/{id}` — Update transaction
* `DELETE /api/v1/transactions/{id}` — Delete transaction

### Analytics & Summaries
* `GET /api/v1/analytics/monthly-summary?year=2026&month=10` — Net savings, income vs expense totals, savings rate percentage, and category breakdowns

### Budgets
* `POST /api/v1/budgets` — Set or update monthly category spending limit
* `GET /api/v1/budgets?year=2026&month=10` — View category limits for month
* `GET /api/v1/budgets/progress?year=2026&month=10` — Spending progress against limits with status alerts (`SAFE`, `WARNING_80`, `EXCEEDED`)

### Savings Goals
* `POST /api/v1/savings-goals` — Create target savings goal
* `GET /api/v1/savings-goals` — List all user goals with completion percentages
* `POST /api/v1/savings-goals/{id}/contributions` — Record atomic deposit/contribution towards goal
* `GET /api/v1/savings-goals/{id}/contributions` — View contribution history
