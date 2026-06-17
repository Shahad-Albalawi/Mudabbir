# Mudabbir (مُدَبِّر)

Personal finance app for Arabic and English speakers — track spending, set savings goals, analyze habits, and get AI coaching.

---

## Product overview

| Area | What users get |
|------|----------------|
| **Home** | Balance summary, quick add income/expense, shortcuts |
| **Statistics** | KPIs, charts, behavioral score |
| **Goals** | Savings targets with progress and milestones |
| **Budget** | Monthly limits with spend tracking |
| **Challenges** | Social saving challenges (server-synced) |
| **Chatbot** | Bilingual financial assistant |
| **Reports** | Shareable monthly PDF (Thmanyah font, SAR ﷼) |

**Design:** Thmanyah typography, light/dark themes, iOS-inspired layout, official wallet logo.

---

## Repository layout

```
├── frontend/          Flutter app (iOS, Android, desktop, web)
├── backend/           Laravel REST API (challenges, expenses, goals, AI)
├── docs/              Deployment notes (e.g. Render)
├── scripts/           Build & backend helpers
└── screenshots/       Store / README visuals
```

### Frontend architecture (`frontend/lib/`)

| Layer | Responsibility |
|-------|----------------|
| `presentation/` | UI, view models (Riverpod / Stacked where legacy) |
| `domain/` | Models, repositories, business rules |
| `data/` | SQLite, Hive cache, Dio HTTP |
| `service/` | DI (GetIt), routing, popups, reporting |
| `constants/` | API flags, Hive keys |
| `utils/` | Debug logging (`devLog` — release-safe) |

Shared UI: `AppCard`, `AppAsyncView`, `IOSEmptyState`, `NavigationService` snackbars.

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

See `docs/DEPLOY_RENDER.md` for Render, or **`docs/DEPLOY_LARAVEL_CLOUD.md`** to restore Laravel Cloud (الخيار أ).

**Production API status:** The default Laravel Cloud URL (`gemini-api-s-challenges-uvxa39.laravel.cloud`) currently returns **Cloudflare 530 / error 1016** (origin unreachable). See `docs/PRODUCTION_API.md` for diagnosis. Verify any host with `scripts/check-production-api.ps1`.

---

## Release checklist

- [ ] Set `API_BASE_URL` in `frontend/config/release.json`
- [ ] Build release: `scripts/build-release-apk.ps1`
- [ ] Verify login/register (no guest bypass in release)
- [ ] Confirm `devLog` / Dio logging silent in release
- [ ] Test offline: expenses/goals use local SQLite + sync
- [ ] Replace launcher icons if needed (`android/app/src/main/res`, iOS `AppIcon`)

---

## Tech stack

- **Client:** Flutter, Riverpod, GetIt, SQLite, Hive, Dio, fl_chart, pdf
- **Server:** Laravel 9, REST, OpenAI/Gemini integrations
- **Fonts:** Thmanyah (primary), Tajawal (fallback glyphs)

---

## License & attribution

Graduation / portfolio project. Thmanyah font © Thmanyah; use per their license for production.
