# Deploying `Backend` on Render

Everything required to build and run the Spring Boot multi-module backend on **Render** is self-contained inside this `Backend/` directory:
- [`Dockerfile`](./Dockerfile): Multi-stage Gradle 8.10 + JDK 21 build and Alpine JRE 21 runtime tuned for Render's 512 MB RAM container limit.
- [`.dockerignore`](./.dockerignore): Excludes local build caches and logs so Docker context uploads fast.
- [`PocketLedgerServiceApplication.java`](./pocketledger-service/src/main/java/com/pocketledger/PocketLedgerServiceApplication.java): Automatically parses Render's `DATABASE_URL` (`postgresql://user:pass@host/db`) into Spring Boot JDBC properties (`jdbc:postgresql://host:5432/db` + username + password).
- [`HealthController.java`](./pocketledger-service/src/main/java/com/pocketledger/controller/HealthController.java): Exposes public `/`, `/health`, and `/api/v1/health` endpoints for Render's health check probe.
- [`render.yaml`](./render.yaml): Render Blueprint configuration inside `Backend/`.

---

## Step-by-Step: Deploying from the Render Dashboard (`/Backend` Root Directory)

### Step 1: Create Your PostgreSQL Database on Render
1. Go to [dashboard.render.com](https://dashboard.render.com/) and click **New +** -> **PostgreSQL**.
2. Fill in:
   - **Name**: `pocketledger-db`
   - **Database**: `pocketledger_db`
   - **Instance Type**: `Free`
3. Click **Create Database**.
4. Once status is **Available**, scroll to **Connections** and copy the **Internal Database URL** (it looks like `postgresql://pocketledger_db_user:xxxx@dpg-xxxx-a/pocketledger_db`).

---

### Step 2: Create Your Web Service Pointing to `Backend`
1. Click **New +** -> **Web Service** and connect your **PocketLedger** GitHub repository.
2. Fill in the service settings:
   - **Name**: `pocketledger-backend`
   - **Root Directory**: `Backend`
   - **Runtime**: `Docker`
   - **Instance Type**: `Free` (or `Starter`)
3. Scroll down to **Environment Variables** and add these **3 variables**:

| Key | Value |
| :--- | :--- |
| `DATABASE_URL` | Paste the **Internal Database URL** from Step 1 (`postgresql://...`) |
| `SPRING_PROFILES_ACTIVE` | `prod` |
| `JWT_SECRET` | `404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970` *(or any 64+ character secret)* |

*(Note: Because `PocketLedgerServiceApplication` auto-parses `DATABASE_URL`, you do **not** even need to split out username, password, or add `jdbc:` manually—just paste Render's Internal Database URL directly into `DATABASE_URL`!)*

4. Under **Advanced** (optional):
   - **Health Check Path**: `/api/v1/health`
5. Click **Create Web Service**.

---

## Verifying Your Live Deployment
Once Render finishes building the Docker image and marks the service **Live**:
- **Health Check**: `https://<your-service-name>.onrender.com/api/v1/health`
- **Swagger UI**: `https://<your-service-name>.onrender.com/swagger-ui.html`

