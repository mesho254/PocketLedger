# PocketLedger Mobile (Flutter)

Production-style Personal Finance & Budgeting client built with **Flutter 3.x** and **Riverpod 2.x**.

---

## Architectural Structure

```
Frontend/
├── lib/
│   ├── core/
│   │   ├── constants/       # API endpoints, colors, layout tokens
│   │   ├── network/         # Dio HTTP client, JWT auth interceptor, exception mapping
│   │   ├── storage/         # FlutterSecureStorage encrypted token persistence
│   │   └── theme/           # Material 3 financial dark theme with Google Fonts
│   ├── data/
│   │   ├── models/          # Strongly typed models with JSON serialization
│   │   └── repositories/    # Remote data access layer
│   ├── presentation/
│   │   ├── providers/       # Riverpod StateNotifiers (Auth, Ledger, Budgets, Savings)
│   │   ├── screens/         # Splash guard, Login, Register, Dashboard, Ledger, Budgets, Goals
│   │   └── widgets/         # Reusable design components (StatCards, Category Tiles, Charts)
│   └── main.dart            # Application entrypoint with ProviderScope
└── test/                    # Unit and widget test suite
```

---

## Features
1. **JWT Authentication & Session Guard**: Automatic token attachment via Dio interceptors, auto-logout on 401 Unauthorized, and persistent encrypted storage.
2. **Interactive Financial Dashboard**: Hero net monthly savings card, cash flow stat cards, and dynamic category breakdown donut charts (`fl_chart`).
3. **Live Transaction Ledger**: Income & expense logging, category filtering chips, and swipe-to-delete.
4. **Monthly Category Budgets**: Visual threshold indicators (`SAFE` green, `WARNING_80` amber, `EXCEEDED` red).
5. **Savings Milestones**: Target amounts, completion progress bars, and atomic deposit recording.

---

## Running Locally

### 1. Ensure Backend is Running
Verify the Spring Boot backend is active on `http://localhost:8080` (or `10.0.2.2:8080` in Android emulator).

### 2. Install Dependencies
```bash
cd Frontend
flutter pub get
```

### 3. Run Tests
```bash
flutter test
```

### 4. Run the App
```bash
flutter run
```
*(Supports Android, iOS, Web, and Desktop)*
