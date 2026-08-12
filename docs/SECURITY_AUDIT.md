# Mudabbir Security Audit

**Date:** 2026-08-12  
**Scope:** Frontend (Flutter) + Backend (Laravel API)  
**Auditor:** Automated review + hardening pass

---

## Executive summary

| Area | Status | Action taken |
|------|--------|--------------|
| Token storage | ✅ Compliant | Access token in `flutter_secure_storage` only; legacy Hive migration added |
| Refresh token | ℹ️ N/A | Sanctum mobile flow uses single bearer token (no refresh_token) |
| Hardcoded secrets | ✅ Clean | No production API keys in repo; public URLs only |
| Rate limiting | ✅ Strengthened | Login + AI endpoints throttled (middleware + app lockout) |
| IDOR / user isolation | ✅ Verified | All resource stores scoped by `user_id`; tests extended |
| Git secret history | ✅ Clean | No `.env` files ever committed |
| Input validation | ✅ Dual-layer | Form requests (backend) + validators (frontend) |

---

## 1. Token storage (access / refresh)

### Finding

- **Access token:** Stored via `AuthTokenSecureStore` → `flutter_secure_storage` (Keychain / Android Keystore with `encryptedSharedPreferences`).
- **Refresh token:** **Not used.** Laravel Sanctum issues one mobile token (`mudabbir-mobile`); there is no OAuth-style refresh rotation in this stack.
- **SharedPreferences:** Used only for non-sensitive prefs (theme, language, onboarding, notification toggle, biometric lock toggle).
- **Hive `savedToken`:** Legacy key; **no code path writes tokens to Hive anymore.** Login explicitly deletes `HiveConstants.savedToken`.

### Changes made

| File | Change |
|------|--------|
| `frontend/lib/service/security/auth_token_secure_store.dart` | Renamed key to `mudabbir.auth.access_token`; auto-migrates legacy `bearer_token` key; enables encrypted shared prefs on Android |
| `frontend/lib/service/security/auth_token_migration.dart` | **New** — one-time migration from Hive → secure storage, then deletes Hive copy |
| `frontend/lib/core/providers/app_bootstrap.dart` | Runs migration on app start |

### Verification

- `DioClient` reads token only from `AuthTokenSecureStore` (interceptor).
- `AuthNotifier`, `AuthService`, `api_service.dart` write/clear secure store on login/logout.
- `hasApiSession()` reads secure storage only.

---

## 2. Hardcoded secrets scan

### Method

Ripgrep across `*.dart`, `*.php`, `*.json`, `*.yaml`, `*.env*` for API keys, tokens, passwords.

### Findings

| Item | Location | Risk | Resolution |
|------|----------|------|------------|
| Production API URL | `frontend/lib/constants/api_constants.dart`, `frontend/config/release.json` | **None** — public HTTPS endpoint | Kept; override via `--dart-define=API_BASE_URL` |
| Test password `password123` | `backend/tests/Concerns/AuthenticatesUsers.php` | **None** — test-only | Documented; not used in production |
| `FCM_TEST_TOKEN` | `frontend/lib/service/notifications/push_notification_service.dart` | **None** — compile-time dart-define for dev | Documented in code |
| OpenAI / Gemini / FCM keys | `backend/.env.example`, `render.yaml` | **None** — placeholders with `sync: false` | Must be set in Render/host env |
| No `sk-…`, `AIza…`, `ghp_…` patterns | — | ✅ | — |

### Backend secrets (correct pattern)

All sensitive values load from environment:

- `OPENAI_API_KEY`, `GEMINI_API_KEY`, `FCM_SERVER_KEY`, `APP_KEY`, `MAIL_*` → `backend/config/*.php`

### Frontend secrets (correct pattern)

No API keys in Flutter binary. Configuration via:

- `--dart-define=API_BASE_URL=…`
- `--dart-define-from-file=config/release.json`
- `--dart-define=FCM_TEST_TOKEN=…` (dev only)

---

## 3. Rate limiting

### Existing (confirmed)

| Route | Middleware | App-level |
|-------|------------|-----------|
| `POST /api/login` | `throttle:auth-login` | `AuthService` — 5 failed attempts / 60s lockout per email+IP |
| `POST /api/ai/chat` | `throttle:ai` | — |
| `POST /api/generate-content` | `throttle:ai` | — |
| `POST /api/register` | `throttle:auth-register` | 5/min per IP |
| `POST /api/auth/forgot-password` | `throttle:auth-password-reset` | 5/min per IP+email |

### Changes made (`RouteServiceProvider`)

| Limiter | Before | After |
|---------|--------|-------|
| `auth-login` | 20/min per IP+email | **10/min** per IP+email |
| `ai` | 20/min per user/IP | **12/min + 120/hour** per user/IP |

### Tests

- `backend/tests/Feature/RateLimitingTest.php` — updated limits; added `test_ai_chat_rate_limit_returns_429`

---

## 4. IDOR / user data isolation

### Pattern

All authenticated controllers derive `$userId = (int) $request->user()->id` and pass it to store layers:

- `ExpenseStore::find/update/delete($id, $userId)`
- `GoalStore`, `BudgetStore` — same pattern
- `ReportService::monthlyForUser($userId)`
- `DashboardService::forUser($userId)`
- `NotificationController` — `where('user_id', $userId)`
- `DeviceTokenController` — scoped to authenticated user

Cross-user access returns **404** (not 403) to avoid resource enumeration.

### Tests

| File | Coverage |
|------|----------|
| `UserDataIsolationTest` | Expenses list/show/update/delete isolation; goals; monthly reports per user |
| `ExpensesApiTest`, `GoalsApiTest`, `BudgetsApiTest` | CRUD workflows |
| `ChallengesApiTest` | Challenge membership (intentional shared resource) |

### Challenges note

Challenges are **multi-user by design** (participants, invitations). Access is gated by challenge membership, not sole `user_id` ownership — documented as expected behaviour.

---

## 5. Git history & `.gitignore`

### Commands run

```bash
git log --all --full-history -- .env backend/.env frontend/.env
git log --all --full-history --diff-filter=A --name-only -- "*.env"
git log --all -p -S "OPENAI_API_KEY" -- backend/.env.example
git log --all -p -S "sk-" 
```

### Result

- **No `.env` file was ever committed** to git history.
- Only `backend/.env.example` (placeholder template) appears in history.
- `.gitignore` correctly excludes:
  - `backend/.env`, `backend/.env.*`
  - `frontend/.env`, `frontend/.env.*`
  - `**/key.properties`, `*.jks`, `*.keystore`
  - `backend/storage/*.key`

### Action required

**None** — no leaked secrets found in git history. If credentials were ever shared outside git (e.g. chat, Render dashboard screenshots), rotate them independently.

---

## 6. Input validation (frontend + backend)

### Login

| Field | Frontend (`AuthValidators`) | Backend (`LoginRequest`) |
|-------|----------------------------|--------------------------|
| email | Required, regex format | Required, email, max 255 |
| password | Required, min 8 | Required, string, max 255 |

### Register

| Field | Frontend | Backend (`RegisterRequest`) |
|-------|----------|----------------------------|
| name | Required | Required, max 255 |
| email | Required, format | Required, unique, email |
| password | Min 8 | Min 8, confirmed (`Password` rule) |
| confirmation | Must match | `password_confirmation` |

### Add expense

| Field | Frontend (`FinancialFormValidators`) | Backend (`StoreExpenseRequest`) |
|-------|-------------------------------------|--------------------------------|
| amount | Required, > 0, max 999999999 | Required, numeric, min 0.01 |
| date | Required, not future | Required, date, before_or_equal:today |
| account_id | Required selection | Required, integer, min 1 |
| category_id | Required selection | Required, integer, min 1 |
| notes | Max 500 | Nullable, max 500 |
| type | — | Optional, in:expense,income |

### Tests added

- `ExpensesApiTest::test_expense_create_validates_required_fields`

---

## 7. Recommendations (future)

1. **Refresh tokens:** If long-lived sessions are required, implement Sanctum token expiration + refresh endpoint; store refresh token in secure storage only.
2. **Certificate pinning:** Consider for production API in high-threat environments.
3. **FCM HTTP v1:** Migrate from legacy server key to service-account JSON (not in repo).
4. **Security headers:** Add `SecureHeaders` middleware on Laravel for HSTS, X-Frame-Options in production.
5. **Dependency audit:** Run `composer audit` / `flutter pub outdated` in CI.

---

## 8. Files changed in this audit

```
frontend/lib/service/security/auth_token_secure_store.dart
frontend/lib/service/security/auth_token_migration.dart
frontend/lib/core/providers/app_bootstrap.dart
backend/app/Providers/RouteServiceProvider.php
backend/app/Http/Requests/Auth/RegisterRequest.php
backend/tests/Feature/RateLimitingTest.php
backend/tests/Feature/UserDataIsolationTest.php
backend/tests/Feature/ExpensesApiTest.php
docs/SECURITY_AUDIT.md
```

---

## Sign-off checklist

- [x] Access token in secure storage only
- [x] No refresh token in insecure storage (N/A — not issued)
- [x] Hardcoded secrets scan documented
- [x] Rate limits on login + AI chat
- [x] IDOR checks verified + tests
- [x] Git history scanned for `.env`
- [x] Dual validation login / register / expense
- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — 61/61 passing
