# PocketLedger: Technical Interview Guide & Defense

This guide is specifically tailored for **Meshack Otieno** to discuss **PocketLedger** with engineering managers, tech leads, and senior architects in technical interviews.

---

## 🎯 60-Second Elevator Pitch

> *"PocketLedger is a full-stack personal finance and budgeting system built with Flutter and Spring Boot 3 on PostgreSQL. Rather than building a generic CRUD app, I focused on production-grade concerns: eliminating floating-point errors with `BigDecimal` and `NUMERIC(12, 2)`, enforcing strict multi-tenant data isolation at the service layer, implementing stateless JWT authentication in Spring Security 6 with custom Dio interceptors, and orchestrating zero-downtime containerized deployments with multi-stage Docker Compose. The mobile app uses Riverpod for unidirectional state management, with real-time budget threshold warnings and category analytics powered by `fl_chart`."*

---

## 💡 Top 10 Technical Interview Questions & High-Impact Answers

### 1. "Why did you use `BigDecimal` instead of `double` or `float` for financial amounts?"
* **Strong Answer**:  
  *"Floating-point types (`float`, `double`) follow the IEEE 754 standard, which represents decimal numbers using binary fractions. This introduces precision errors in repetitive math (for example, `0.1 + 0.2 != 0.3`). In a financial ledger, even a fraction of a cent discrepancy will corrupt audit trails and budget totals. I used `BigDecimal` with explicit scale and rounding modes (`RoundingMode.HALF_UP`) in Java, mapped to `NUMERIC(12, 2)` in PostgreSQL, ensuring absolute mathematical precision across all balance, expense, and savings calculations."*
* **Where to show in code**: [`Transaction.java`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/model/Transaction.java#L38-L40), [`AnalyticsService.java`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/service/AnalyticsService.java#L47-L62).

---

### 2. "How did you enforce multi-tenancy and prevent horizontal privilege escalation?"
* **Strong Answer**:  
  *"Endpoint security alone isn't enough. I designed a two-tiered security model:*  
  *1. **Security Context**: The `JwtAuthenticationFilter` intercepts requests, validates the signature and expiration, and binds a verified `UserPrincipal` containing the `userId` to Spring's `SecurityContextHolder`.*  
  *2. **Service Layer Isolation**: Every query in `TransactionService`, `BudgetService`, and `SavingsGoalService` explicitly scopes queries to the authenticated user (e.g. `findByIdAndUser(id, user)` or JPA `Specification`). Even if a malicious user guesses another user's UUID, the query yields an empty result and returns an HTTP 404/403, making cross-tenant data leakage impossible."*
* **Where to show in code**: [`TransactionService.java`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/service/TransactionService.java#L48-L62), [`TransactionRepository.java`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/repository/TransactionRepository.java#L21-L40).

---

### 3. "Spring Security 6 changed significantly from version 5. How did you structure your security configuration?"
* **Strong Answer**:  
  *"In Spring Security 6 (Spring Boot 3), `SecurityFilterChain` replaces the deprecated `WebSecurityConfigurerAdapter`. I configured a completely stateless session policy (`SessionCreationPolicy.STATELESS`), disabled CSRF because Bearer tokens are stored in encrypted client storage (immune to traditional cross-site request forgery), enabled a fine-grained CORS policy, and added our custom `JwtAuthenticationFilter` before the `UsernamePasswordAuthenticationFilter`. Public paths like `/api/v1/auth/**` and Swagger `/swagger-ui/**` are explicitly permitted, while all financial endpoints enforce strict authentication."*
* **Where to show in code**: [`SecurityConfig.java`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/config/SecurityConfig.java#L34-L62).

---

### 4. "Why did you choose Flutter Riverpod over BLoC or Provider?"
* **Strong Answer**:  
  *"While Provider relies heavily on the `BuildContext` tree (which makes accessing state outside the widget tree or in background callbacks awkward), and BLoC introduces significant event/state boilerplate for focused mobile apps, Riverpod 2.x offers compile-safe, decoupled state management. It provides:*  
  *• Compile-time dependency safety with zero runtime `ProviderNotFoundException` risk.*  
  *• Clean separation of asynchronous UI states (using `StateNotifierProvider`).*  
  *• Straightforward unit testability without needing to mock the entire Flutter widget tree or context."*
* **Where to show in code**: [`app_providers.dart`](file:///c:/Users/HomePC/Desktop/PocketLedger/Frontend/lib/presentation/providers/app_providers.dart), [`auth_provider.dart`](file:///c:/Users/HomePC/Desktop/PocketLedger/Frontend/lib/presentation/providers/auth_provider.dart#L40-L100).

---

### 5. "How does the mobile app handle token storage and 401 Unauthorized responses?"
* **Strong Answer**:  
  *"JWTs are never stored in plain `SharedPreferences`. I encapsulated `FlutterSecureStorage` (which uses Keychain on iOS and AES encryption with KeyStore on Android) inside `SecureStorageService`. In `ApiClient`, I configured Dio request and error interceptors:*  
  *• **On Request**: Automatically injects `Authorization: Bearer <token>`.*  
  *• **On 401 Error**: Automatically clears the encrypted storage and triggers an `onUnauthorized` callback that directs the reactive auth provider to reset state to `unauthenticated`, smoothly transitioning the user back to the login screen."*
* **Where to show in code**: [`api_client.dart`](file:///c:/Users/HomePC/Desktop/PocketLedger/Frontend/lib/core/network/api_client.dart#L39-L55), [`secure_storage_service.dart`](file:///c:/Users/HomePC/Desktop/PocketLedger/Frontend/lib/core/storage/secure_storage_service.dart#L10-L32).

---

### 6. "How did you optimize PostgreSQL queries for dashboard analytics and category charts?"
* **Strong Answer**:  
  *"Rather than fetching thousands of raw transaction rows into memory and computing totals in Java, which would cause high memory pressure and slow latency, I leveraged PostgreSQL server-side aggregation:*  
  *• Used composite indexing on `(user_id, transaction_date DESC)`.*  
  *• Implemented Spring Data JPA interface projections (`CategorySumProjection`) and aggregate queries (`SELECT COALESCE(SUM(t.amount), 0) ... GROUP BY t.category`).*  
  *This offloads math directly to PostgreSQL's query optimizer and sends only compact summary rows over the network."*
* **Where to show in code**: [`TransactionRepository.java`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/repository/TransactionRepository.java#L25-L48).

---

### 7. "How do you maintain data consistency when contributing to a savings goal?"
* **Strong Answer**:  
  *"Adding a contribution involves two state changes: inserting a `SavingsContribution` log and updating the `currentAmount` and `status` on the `SavingsGoal` parent record. I encapsulated this operation in an `@Transactional` service method. In the event of a database constraint violation or network timeout during the update, Spring automatically rolls back the transaction, preventing orphan contribution logs or out-of-sync balances."*
* **Where to show in code**: [`SavingsGoalService.java`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/service/SavingsGoalService.java#L52-L78).

---

### 8. "How is error handling standardized across the stack?"
* **Strong Answer**:  
  *"I implemented a `@RestControllerAdvice` [`GlobalExceptionHandler`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/exception/GlobalExceptionHandler.java) conforming to the RFC 7807 Problem Details standard. All errors return a predictable JSON payload containing `timestamp`, `status`, `error`, `message`, and field-level `details` for validation failures. In the Flutter client, Dio interceptors parse this payload into an `ApiException`, allowing screens to display user-friendly error banners without raw stack traces."*
* **Where to show in code**: [`GlobalExceptionHandler.java`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/src/main/java/com/pocketledger/exception/GlobalExceptionHandler.java), [`api_client.dart`](file:///c:/Users/HomePC/Desktop/PocketLedger/Frontend/lib/core/network/api_client.dart#L58-L77).

---

### 9. "What are the benefits of your multi-stage Docker build?"
* **Strong Answer**:  
  *"A naive single-stage Docker build bundles the entire JDK (often 500MB+) and source files into production. My multi-stage [`Dockerfile`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/Dockerfile) uses an Eclipse Temurin JDK 21 Alpine image to compile and package the jar, and then copies only the final `.jar` into a lightweight JRE 21 Alpine runtime image. Furthermore, I created a non-root system user (`pocketledger:pocketledger`), mitigating privilege escalation risks in containerized environments."*
* **Where to show in code**: [`Backend/Dockerfile`](file:///c:/Users/HomePC/Desktop/PocketLedger/Backend/Dockerfile).

---

### 10. "If PocketLedger grew to 1,000,000 active users, how would you evolve the architecture?"
* **Strong Answer**:  
  *"I would scale the architecture in four strategic steps:*  
  *1. **Caching**: Introduce Redis to cache monthly summary analytics and category budget progress with a 1-hour TTL, cache-invalidated only when new transactions are logged.*  
  *2. **Database Read Replicas**: Direct analytical queries and GET requests to read-only replicas using PgBouncer connection pooling, reserving the primary database for transactional writes.*  
  *3. **Database Partitioning**: Partition the `transactions` table by range on `transaction_date` (e.g. annual or monthly partitions) so queries only scan relevant date blocks.*  
  *4. **Asynchronous Processing**: Use RabbitMQ or Apache Kafka to process monthly rollover calculations and push notifications asynchronously."*

---

## 🧭 Repository Tour Checklist for Screen Sharing

1. **Start with the live Swagger UI**:
   - Open `http://localhost:8080/swagger-ui/index.html` to showcase API design, schemas, and live documentation.
2. **Show the Mobile Architecture**:
   - Walk through `Frontend/lib/` showcasing clean separation between `core/`, `data/`, and `presentation/`.
3. **Highlight Financial Safety**:
   - Show `BigDecimal` in `Transaction.java` and discuss zero-drift arithmetic.
4. **Demonstrate Automated Testing**:
   - Run `./mvnw test` showing all 10 tests passing with Mockito and MockMvc.
5. **Show One-Command Dockerization**:
   - Run `docker compose up -d` showing Postgres and Spring Boot starting together.
