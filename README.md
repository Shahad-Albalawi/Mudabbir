# Mudabbir (مُدَبِّر)

Personal finance app for Arabic and English speakers — track spending, set savings goals, analyze habits, compete in challenges, and get AI coaching.

---

## Product overview

| Area | What users get |
|------|----------------|
| **Home** | Balance, monthly spending vs budget, insights, goals snapshot, quick add income/expense/goal |
| **Statistics** | Period KPIs, spending trend chart, category breakdown, plain-language insights |
| **Goals** | Savings targets with progress and contributions |
| **Budget** | Monthly limits with spend tracking and alerts |
| **Behavioral analysis** | Health score, savings behavior, category insights |
| **Challenges** | Social saving challenges (server-synced) |
| **Chatbot** | Bilingual financial assistant (SSE streaming) |
| **Reports** | Shareable monthly PDF (Thmanyah font, SAR ﷼, RTL layout) |

**Design:** Navy brand palette (`#112E81`), Thmanyah typography, light/dark themes, iOS-inspired cards and navigation.

### Screenshots (`screenshots/`)

| File | Screen |
|------|--------|
| `home.png` | Home dashboard — balance, budget strip, quick actions |
| `statistics.png` | Statistics tab — KPIs and charts |
| `goals.png` | Goals tab — savings progress |
| `behavior.png` | Behavioral analysis |
| `chatbot.png` | AI assistant |

---

## Repository layout

```
├── frontend/          Flutter app (iOS, Android, desktop, web)
├── backend/           Laravel REST API (auth, expenses, goals, budgets, challenges, AI)
├── docs/              Deployment & Play Store guides
├── scripts/           Build & backend helpers
└── screenshots/       Store / README visuals
```

### Frontend architecture (`frontend/lib/`)

| Layer | Responsibility |
|-------|----------------|
| `presentation/` | UI screens, Riverpod providers/view models |
| `domain/` | Models, repositories, business rules |
| `data/` | SQLite, Hive cache, Dio HTTP |
| `service/` | DI (GetIt), GoRouter, reporting, chatbot |
| `constants/` | Theme, API flags, Hive keys |
| `l10n/` | Arabic / English strings (ARB) |
| `utils/` | Debug logging (`devLog` — release-safe) |

**Navigation**

- **Shell:** `HomePage` — bottom tabs (Home · Statistics · Goals), settings app-bar action, chatbot FAB
- **Routes:** expenses, budget, analysis, chatbot, challenges, invite, settings, privacy (see `app_routes.dart`)
- **Auth flow:** splash → onboarding → login/register → home

Shared UI: `AppCard`, `IOSEmptyState`, `ModernGradientAppBar`, `AppSectionHeader`, design tokens in `constants/app_theme.dart`.

---

## Quick start (development)

### Prerequisites

- Flutter SDK 3.8+
- Android Studio / Xcode (for mobile)
- PHP 8.1+ & Composer (optional, for local API)

### Flutter app

```bash
cd frontend
flutter pub get
flutter run
```

**Debug defaults**

- Guest home + demo data on emulator (`InstantBrowseBootstrap`) — disable with:
  `--dart-define=DISABLE_INSTANT_BROWSE=true`
- API points to `http://10.0.2.2:8000` in debug — start backend:

```powershell
# from repo root
powershell -ExecutionPolicy Bypass -File scripts/start-backend.ps1
```

**Production API at build time**

```bash
flutter build apk --release --dart-define-from-file=config/release.json
# or
flutter run --dart-define=FORCE_PROD_API=true
```

### Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan serve
```

See **`docs/DEPLOY_RENDER_AR.md`** (Render — مُوصى به حالياً) or `docs/DEPLOY_LARAVEL_CLOUD.md` (Laravel Cloud).

**Production API:** `https://mudabbir-backend-api.onrender.com` (Render). Verify: `scripts/check-production-api.ps1`.

### Quality checks

```bash
cd frontend
flutter analyze
flutter test
```

---

## Release checklist

- [ ] Set `API_BASE_URL` in `frontend/config/release.json`
- [ ] Configure Android signing: `frontend/android/key.properties` (see `key.properties.example`)
- [ ] Build for Play Store: `scripts/build-release-aab.ps1` (AAB required; APK for sideload: `build-release-apk.ps1`)
- [ ] Run `flutter analyze` with zero issues
- [ ] Verify login/register (no guest bypass in release)
- [ ] Confirm `devLog` / Dio logging silent in release
- [ ] Test offline sync: expenses, goals, and budgets (SQLite + Hive + Laravel API)
- [ ] Test local notifications: budget 80%/exceeded and goal completion (grant permission on Android 13+)
- [ ] Prepare Play listing: see **`docs/PLAY_STORE.md`** (screenshots, privacy policy, data safety)
- [ ] Replace launcher icons if needed (`android/app/src/main/res`, iOS `AppIcon`)

---

## Tech stack

- **Client:** Flutter, Riverpod, GetIt, GoRouter, SQLite, Hive, Dio, fl_chart, pdf, printing
- **Server:** Laravel 9, Sanctum auth, REST, Gemini AI
- **Fonts:** Thmanyah (primary), Tajawal (fallback glyphs)

---

## License & attribution

Graduation / portfolio project. Thmanyah font © Thmanyah; use per their license for production.
