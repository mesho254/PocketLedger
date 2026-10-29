# PocketLedger Mobile (Flutter)

Modern Personal Finance, Budgeting & Savings Goal mobile application built with **Flutter 3.x** and **Riverpod 2.x**, connected to the live **Spring Boot 3** backend on **Render** (`https://pocketledger-backend.onrender.com/api/v1`).

---

## 📱 Visual Walkthrough

| Dashboard (Light Mode) | Dashboard (Dark Mode) | Transactions Ledger | Record Transaction |
| :---: | :---: | :---: | :---: |
| <img src="../docs/screenshots/01_dashboard_light.png" width="210" alt="Dashboard Light Mode" /> | <img src="../docs/screenshots/02_dashboard_dark.png" width="210" alt="Dashboard Dark Mode" /> | <img src="../docs/screenshots/03_transactions_ledger.png" width="210" alt="Transactions Ledger" /> | <img src="../docs/screenshots/06_record_transaction_sheet.png" width="210" alt="Record Transaction" /> |
| Hero balance, privacy toggle, interactive cashflow spline chart & Overview sparklines. | Obsidian & Luminous Teal dark theme with instant header toggle (`🌙` / `☀️`). | Live search bar, `All` / `Income` / `Expenses` filter pills & date-grouped cards. | Modal sheet with `Expense` / `Income` toggle, category dropdown & date picker. |

| Monthly Budgets | Set Budget Limit | Savings Goals | Create Goal | Deposit to Goal |
| :---: | :---: | :---: | :---: | :---: |
| <img src="../docs/screenshots/04_monthly_budgets.png" width="165" alt="Monthly Budgets" /> | <img src="../docs/screenshots/05_set_budget_dialog.png" width="165" alt="Set Budget Limit" /> | <img src="../docs/screenshots/07_savings_goals.png" width="165" alt="Savings Goals" /> | <img src="../docs/screenshots/08_create_savings_goal.png" width="165" alt="Create Goal" /> | <img src="../docs/screenshots/09_deposit_savings_goal.png" width="165" alt="Deposit to Goal" /> |
| Category spending progress & Smart Budget Insight. | Monthly spending cap dialog per category. | Milestone progress cards & arc gauge. | Target amount & completion date modal. | Atomic contribution deposit dialog. |

### User Profile & Global 10-Currency Switcher
| Profile & Global Currency | Key Capabilities |
| :---: | :--- |
| <img src="../docs/screenshots/10_profile_global_currency.png" width="230" alt="Profile Screen" /> | <ul><li>**User Identity Card**: Displays initials badge, full name, email, active currency, membership date, and live counters for Transactions, Budgets, and Goals.</li><li>**Instant 10-Currency Switcher**: Switch between `USD ($)`, `EUR (€)`, `GBP (£)`, `KES (KSh)`, `NGN (₦)`, `ZAR (R)`, `INR (₹)`, `CAD (CA$)`, `AUD (A$)`, and `JPY (¥)` with immediate reactive updates across every screen.</li><li>**Profile & Security**: Update name, email, currency, password, Dark Mode, and Privacy Balance Mask (`••••`).</li></ul> |

---

## Architectural Structure

```
Frontend/
├── lib/
│   ├── core/
│   │   ├── constants/       # API endpoints (Render Cloud URL) & dual-theme AppPalette
│   │   ├── network/         # Dio HTTP client, JWT auth interceptor & Render warm-up ping
│   │   ├── storage/         # FlutterSecureStorage encrypted token & theme persistence
│   │   ├── theme/           # Light (Editorial Alabaster) & Dark (Obsidian) Material 3 themes
│   │   └── utils/           # Reactive CurrencyFormatter & currencyFormatterProvider
│   ├── data/
│   │   ├── models/          # Strongly typed models with JSON serialization
│   │   └── repositories/    # Remote data access layer
│   ├── presentation/
│   │   ├── providers/       # Riverpod StateNotifiers (Auth, Theme, Ledger, Budgets, Savings)
│   │   ├── screens/         # Splash, Login, Register, MainShell, Dashboard, Ledger, Budgets, Goals, Profile
│   │   └── widgets/         # CashflowSplineChart, SparklineChart, CircularArcGauge, Bento Cards
│   └── main.dart            # Application entrypoint with ProviderScope
└── test/                    # Unit and widget test suite
```

---

## Running & Building

```bash
cd Frontend

# Install dependencies
flutter pub get

# Run unit & widget tests
flutter test

# Run on Android Emulator
flutter run -d emulator-5554

# Build Production Release APK (connected to https://pocketledger-backend.onrender.com/api/v1)
flutter build apk --release --android-skip-build-dependency-validation
```
