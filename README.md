# PocketLedger 🪙

[![Java](https://img.shields.io/badge/Java-21%20LTS-orange.svg?style=flat-square&logo=openjdk)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.5-brightgreen.svg?style=flat-square&logo=springboot)](https://spring.io/projects/spring-boot)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?style=flat-square&logo=flutter)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16%20Alpine-336791.svg?style=flat-square&logo=postgresql)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose%20Ready-2496ED.svg?style=flat-square&logo=docker)](https://www.docker.com/)
[![Security](https://img.shields.io/badge/Auth-JWT%20%2B%20BCrypt-red.svg?style=flat-square)](https://jwt.io/)

> **PocketLedger** is a full-stack personal finance and budgeting mobile ecosystem engineered to demonstrate production-grade architecture. It combines a reactive **Flutter** mobile client with an enterprise-ready **Spring Boot 3** REST API backed by **PostgreSQL 16**.

---

## 🌟 System Architecture

```mermaid
graph TD
    subgraph Mobile ["Flutter Mobile Client (Dart)"]
        UI["UI Layer (Material 3 Dark Slate Theme)"]
        State["State Management (Riverpod 2.x Notifiers)"]
        Client["Network Client (Dio + Auth Interceptors)"]
        Storage["Flutter Secure Storage (Encrypted JWT)"]
        
        UI --> State
        State --> Client
        Client --> Storage
    end

    subgraph Backend ["Spring Boot 3 REST API (Java 21)"]
        Security["Spring Security 6 (Stateless JWT Filter)"]
        Controllers["Controllers (Bean Validation + OpenAPI)"]
        Services["Service Layer (@Transactional Business Logic)"]
        Repos["Data Access (Spring Data JPA)"]
        
        Security --> Controllers
        Controllers --> Services
        Services --> Repos
    end

    subgraph Database ["Persistence Layer"]
        PG[("PostgreSQL 16 Alpine")]
        Repos --> PG
    end

    Client -->|HTTPS / JSON + Bearer JWT| Security
```

---

## 🗄️ Relational Database Schema

```mermaid
erDiagram
    USERS ||--o{ TRANSACTIONS : owns
    USERS ||--o{ BUDGETS : defines
    USERS ||--o{ SAVINGS_GOALS : sets
    SAVINGS_GOALS ||--o{ SAVINGS_CONTRIBUTIONS : receives

    USERS {
        uuid id PK
        varchar email UK
        varchar password_hash
        varchar full_name
        varchar currency
        timestamp created_at
    }

    TRANSACTIONS {
        uuid id PK
        uuid user_id FK
        numeric amount "12, 2"
        varchar type "INCOME | EXPENSE"
        varchar category
        date transaction_date
        varchar description
        timestamp created_at
    }

    BUDGETS {
        uuid id PK
        uuid user_id FK
        varchar category
        numeric monthly_limit "12, 2"
        int budget_month
        int budget_year
    }

    SAVINGS_GOALS {
        uuid id PK
        uuid user_id FK
        varchar title
        numeric target_amount "12, 2"
        numeric current_amount "12, 2"
        date target_date
        varchar status "IN_PROGRESS | COMPLETED"
        timestamp created_at
    }

    SAVINGS_CONTRIBUTIONS {
        uuid id PK
        uuid savings_goal_id FK
        numeric amount "12, 2"
        date contribution_date
        varchar note
        timestamp created_at
    }
```

---

## 🚀 Key Engineering Pillars

### 1. Financial Accuracy & Multi-Tenancy
* **Zero Floating-Point Drift**: All currency amounts in Java are modeled using `BigDecimal` and mapped to `NUMERIC(12, 2)` in PostgreSQL. Standard IEEE 754 floating-point arithmetic is strictly avoided.
* **Strict Tenancy Isolation**: Security isn't just checked at endpoints; every JPA query and service operation enforces `WHERE user_id = :authenticatedUserId` to guarantee complete privacy across user accounts.

### 2. Enterprise Spring Security 6 & JWT
* Stateless session architecture using HMAC-SHA256 tokens (`JJWT 0.12`).
* Passwords hashed with BCrypt.
* Auto-configured OpenAPI 3.0 (Swagger UI) with interactive Bearer Authentication support.

### 3. Reactive Mobile Architecture (Flutter + Riverpod)
* Layered separation: `core/`, `data/`, and `presentation/`.
* Dio HTTP client equipped with request interceptors to auto-attach tokens and error interceptors to trigger smooth session redirects on 401s.
* Responsive `fl_chart` donut visualizations and real-time budget threshold warnings (`SAFE` green, `WARNING_80` amber, `EXCEEDED` red).

### 4. Atomic Transactional Integrity
* Savings goal deposits use Spring's `@Transactional` boundary to guarantee that both the contribution log entry and the updated target balance persist atomically.

---

## ⚡ Quickstart & Deployment

### Option A: One-Command Docker Compose (Recommended)

Starts both **PostgreSQL 16** and the **Spring Boot API** in isolated containers:

```bash
docker compose up -d --build
```

* API Base URL: `http://localhost:8080`
* Interactive Swagger UI: `http://localhost:8080/swagger-ui/index.html`
* OpenAPI JSON Spec: `http://localhost:8080/api-docs`
* PostgreSQL Port: `localhost:5433` (DB: `pocketledger_db`, User: `postgres`, Pass: `postgrespassword`)

---

### Option B: Running the Backend Locally

```bash
# 1. Start PostgreSQL
docker compose up -d postgres

# 2. Compile and run test suite (100% pass)
cd Backend
./mvnw clean test

# 3. Start Spring Boot
./mvnw spring-boot:run
```

---

### Option C: Running the Flutter Mobile Client

```bash
cd Frontend

# 1. Install Flutter dependencies
flutter pub get

# 2. Run unit & widget tests (100% pass)
flutter test

# 3. Check connected devices
flutter devices

# 4. Launch on Android Emulator (Recommended)
flutter run -d emulator-5554
# or on Chrome
flutter run -d chrome
```

---

## 📚 REST API Reference

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/register` | Create user account | No |
| `POST` | `/api/v1/auth/login` | Authenticate & get JWT | No |
| `GET` | `/api/v1/auth/me` | Fetch authenticated profile | Yes |
| `GET` | `/api/v1/transactions` | List/filter transactions (page, size, type, category, date range) | Yes |
| `POST` | `/api/v1/transactions` | Record income or expense | Yes |
| `PUT` | `/api/v1/transactions/{id}` | Update existing transaction | Yes |
| `DELETE` | `/api/v1/transactions/{id}` | Delete transaction | Yes |
| `GET` | `/api/v1/analytics/monthly-summary` | Income, expense, net savings & category breakdown | Yes |
| `GET` | `/api/v1/budgets/progress` | Budget limits vs actual spending with warning flags | Yes |
| `POST` | `/api/v1/budgets` | Set or update monthly category budget | Yes |
| `GET` | `/api/v1/savings-goals` | List savings goals with progress percentages | Yes |
| `POST` | `/api/v1/savings-goals` | Create target savings goal | Yes |
| `POST` | `/api/v1/savings-goals/{id}/contributions` | Record deposit towards savings goal | Yes |

---

## 🧪 Testing Strategy

* **Spring Boot**:
  * `AuthServiceTest`: Unit testing registration and login edge-cases using Mockito.
  * `TransactionServiceTest`: Verifies user tenancy isolation and ownership checks.
  * `AnalyticsServiceTest`: Verifies math calculations (savings rates, percentage ratios).
  * `AuthControllerTest`: MockMvc slice testing for HTTP status codes and RFC 7807 validation responses.
* **Flutter**:
  * `models_test.dart`: Serialization, date parsing, and computed status logic tests.

---

## 👨‍💻 Project Information
* **Developer**: Meshack Otieno
* **Specialization**: Spring Boot & Flutter Full-Stack Software Engineer
* **License**: MIT
