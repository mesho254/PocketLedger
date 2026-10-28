# PocketLedger — Comprehensive Multi-Module Architecture & API Reference

## 1. Architecture Overview

PocketLedger follows the **Trinity Software Solutions Multi-Module Gradle Architecture**:

- **`auth`** (Base Module): Provides shared Spring Boot starters (`web`, `data-jpa`, `security`, `validation`), MapStruct (`PocketLedgerMapperConfig`), JPA Auditing (`BaseAuditableEntity`, `AuditingConfig`), JWT authentication (`JwtService`, `JwtAuthenticationFilter`), refresh token rotation, and user profile management.
- **`transaction`**: Manages personal income and expense records (`Transaction`), dynamic filtering (`JpaSpecificationExecutor`), category aggregation queries, `TransactionValidator`, `TransactionMapper`, and `TransactionRecordedEvent`.
- **`budget`**: Manages monthly category spending limits (`Budget`) and computes real-time budget progress with status alerts (`SAFE`, `WARNING_80`, `EXCEEDED`).
- **`savings`**: Manages target savings goals (`SavingsGoal`) and atomic deposit logs (`SavingsContribution`) with completion tracking.
- **`analytics`**: Computes monthly financial summaries (`MonthlySummaryResponse`), net savings rate percentages, and category expense breakdowns (`CategoryBreakdownResponse`).
- **`pocketledger-service`**: The runnable aggregator module (`PocketLedgerServiceApplication`) that packages all domain modules and connects to local PostgreSQL (`pocketledger_db`).

---

## 2. Standard Module Package Layout

Every domain module follows the identical internal package convention:

```text
<module>/src/main/java/com/pocketledger/<module>/
├── controller/   # REST controllers (@RestController)
├── service/      # Business logic interfaces (*Service) and implementations (*ServiceImpl)
├── repository/   # Spring Data JPA repositories (*Repository)
├── entity/       # JPA entities extending BaseAuditableEntity
├── enums/        # Domain enumerations
├── dto/          # Request and Response DTOs
├── mapper/       # MapStruct mappers (@Mapper(config = PocketLedgerMapperConfig.class))
├── validation/   # Dedicated @Component validators (*Validator)
├── exception/    # Module exceptions and @RestControllerAdvice (*ExceptionHandler)
└── event/        # Domain events extending DomainEvent
```

---

## 3. Complete REST API Endpoints

| Module | Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **auth** | `POST` | `/api/v1/auth/register` | Register a new user account |
| **auth** | `POST` | `/api/v1/auth/login` | Authenticate user and receive access + refresh tokens |
| **auth** | `POST` | `/api/v1/auth/refresh` | Rotate refresh token and issue new access token |
| **auth** | `POST` | `/api/v1/auth/logout` | Revoke refresh token and blacklist access token |
| **auth** | `POST` | `/api/v1/auth/change-password` | Change password for authenticated user |
| **auth** | `GET` | `/api/v1/auth/me` | Retrieve current authenticated user profile |
| **transaction** | `POST` | `/api/v1/transactions` | Record an `INCOME` or `EXPENSE` transaction |
| **transaction** | `GET` | `/api/v1/transactions` | List/filter transactions (`startDate`, `endDate`, `type`, `category`, `page`, `size`) |
| **transaction** | `GET` | `/api/v1/transactions/{id}` | Get transaction by ID |
| **transaction** | `PUT` | `/api/v1/transactions/{id}` | Update transaction by ID |
| **transaction** | `DELETE` | `/api/v1/transactions/{id}` | Delete transaction by ID |
| **budget** | `POST` | `/api/v1/budgets` | Set or update monthly category budget limit |
| **budget** | `GET` | `/api/v1/budgets` | List budgets for `year` and `month` |
| **budget** | `GET` | `/api/v1/budgets/progress` | Compute spending progress vs limits (`SAFE`, `WARNING_80`, `EXCEEDED`) |
| **budget** | `DELETE` | `/api/v1/budgets/{id}` | Delete a budget limit |
| **savings** | `POST` | `/api/v1/savings-goals` | Create a new target savings goal |
| **savings** | `GET` | `/api/v1/savings-goals` | List all savings goals with completion percentage |
| **savings** | `GET` | `/api/v1/savings-goals/{id}` | Get single savings goal by ID |
| **savings** | `POST` | `/api/v1/savings-goals/{id}/contributions` | Record atomic contribution deposit towards goal |
| **savings** | `GET` | `/api/v1/savings-goals/{id}/contributions` | List contribution history for goal |
| **savings** | `DELETE` | `/api/v1/savings-goals/{id}` | Delete a savings goal |
| **analytics** | `GET` | `/api/v1/analytics/monthly-summary` | Get monthly income, expense, net savings, savings rate & category breakdown |

