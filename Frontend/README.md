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

#### Run on Connected Android Emulator (Recommended):
```bash
# Check connected devices
flutter devices

# Run on Android Emulator (API 36 / 10.0.2.2 auto-maps to backend)
flutter run -d emulator-5554
# or
flutter run -d android
```

#### Run on Web (Fast Browser Testing):
```bash
# Launch in Google Chrome
flutter run -d chrome

# Launch in Microsoft Edge
flutter run -d edge
```

#### Run on Windows Desktop:
```bash
flutter run -d windows
```
> **Note**: Building Windows desktop with native plugins requires Windows Developer Mode. If prompted, run `start ms-settings:developers` and toggle **Developer Mode** to **On**.

---

## 🛠️ Helpful Commands & Troubleshooting

| Command | Purpose |
| :--- | :--- |
| `flutter devices` | List all running emulators, physical phones, and browsers |
| `flutter test` | Run the complete unit and widget test suite (6/6 tests) |
| `flutter create .` | Re-generate platform wrappers (`android/`, `ios/`, `web/`, `windows/`) if needed |
| `flutter clean && flutter pub get` | Clear build artifacts and re-fetch dependencies |
| `export PATH="$PATH:/c/Users/HomePC/flutter/bin"` | Temporarily export Flutter to terminal PATH if needed |
