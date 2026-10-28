# Getting Started with PocketLedger Backend (Local PostgreSQL & pgAdmin 4)

## 1. Verify Local PostgreSQL Database in pgAdmin 4
1. Open **pgAdmin 4** on your computer.
2. Expand **Servers** → **PostgreSQL 18** → **Databases** → **`pocketledger_db`**.
3. Expand **`Schemas (1)`** → **`public`** → **`Tables`**.
4. Default connection details configured in `pocketledger-service/src/main/resources/application.properties`:
   - **Host**: `localhost`
   - **Port**: `5432`
   - **Database**: `pocketledger_db`
   - **Username**: `postgres`
   - **Password**: `root`

## 2. Build & Start the Multi-Module Backend
From PowerShell inside `C:\Users\HomePC\Desktop\PocketLedger\Backend`:

```powershell
# Compile and run all module unit tests
.\gradlew.bat test

# Start the unified PocketLedger Spring Boot application
.\gradlew.bat :pocketledger-service:bootRun
```

Once started, refresh **`Tables`** under `pocketledger_db -> Schemas -> public` in **pgAdmin 4** (Right-click `Tables` → **Refresh...**). You will see all 6 tables created automatically:
- `users`
- `refresh_tokens`
- `transactions`
- `budgets`
- `savings_goals`
- `savings_contributions`

## 3. Explore the API
- **Swagger UI**: `http://localhost:8080/swagger-ui/index.html`
- **Postman**: Import `PocketLedger_Postman_Collection.json` into Postman.

