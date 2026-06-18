# Production API — diagnosis & remediation

Current default production host (Flutter `release.json` / `api_constants.dart`):

```text
https://laravel-main-nb0wjv.laravel.cloud
```

> **Do not use** `*.free.laravel.cloud` — that hostname does not exist in DNS (NXDOMAIN). Laravel Cloud URLs are `https://<env>.laravel.cloud`.

Legacy host (removed from the app):

```text
https://gemini-api-s-challenges-uvxa39.laravel.cloud
```

## Diagnosis (2026-06-17)

| Check | `laravel-main-nb0wjv.laravel.cloud` | `*.free.laravel.cloud` |
|-------|--------------------------------------|-------------------------|
| Public DNS | **OK** — Cloudflare anycast | **FAIL** — NXDOMAIN |
| `GET /api/health` | **FAIL** — HTTP 530, `error code: 1016` | N/A |
| `Server` header | `cloudflare` | — |

### Root cause

**Cloudflare error 1016 (HTTP 530)** means the edge receives the request but **cannot route to the Laravel Cloud origin**. This is an infrastructure/deploy issue, not a Flutter or Laravel bug.

Typical causes:

1. Environment **stopped**, **paused**, or **never finished deploying**
2. Failed deployment leaving a broken origin mapping
3. Build commands typo (use `bash cloud-build.sh`, not manual `composer` with typos)

The GitHub side is ready: branch **`laravel-cloud`** is synced from `main` (backend at repo root) via `.github/workflows/laravel-cloud-branch.yml`.

## Fixes

### Option A — Laravel Cloud (primary)

**Step-by-step (Arabic):** [DEPLOY_LARAVEL_CLOUD.md](./DEPLOY_LARAVEL_CLOUD.md)

1. Sign in to [Laravel Cloud](https://cloud.laravel.com/).
2. Open project **laravel-main** (or the env that owns `laravel-main-nb0wjv.laravel.cloud`).
3. **Branch:** `laravel-cloud` (not `main`).
4. **Build:** `bash cloud-build.sh` — **Deploy:** `bash cloud-deploy.sh`.
5. If deploy did not start after a push: **Redeploy** from the dashboard.
6. Environment variables:

   | Variable | Value |
   |----------|--------|
   | `APP_URL` | `https://laravel-main-nb0wjv.laravel.cloud` |
   | `APP_KEY` | from `php artisan key:generate --show` |
   | `APP_ENV` | `production` |
   | `APP_DEBUG` | `false` |

7. Verify:

   ```powershell
   curl.exe -sS "https://laravel-main-nb0wjv.laravel.cloud/api/health"
   ```

   Expect **200** and `"status": "ok"`.

   Or:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1
   ```

If the environment was deleted, create a new one and update `frontend/config/release.json` + `api_constants.dart`.

### Option B — Render (fallback)

See [DEPLOY_RENDER.md](./DEPLOY_RENDER.md) and `backend/render.yaml`.

## Flutter — locked to backend

| Build | API host |
|-------|----------|
| **Debug** (default) | `http://10.0.2.2:8000` (local Laravel) |
| **Release** | `https://laravel-main-nb0wjv.laravel.cloud` via `release.json` |
| **Override** | `--dart-define=API_BASE_URL=...` or `FORCE_PROD_API=true` in debug |

All HTTP (Dio, login, register, sync, chatbot) uses `ApiConstants.baseUrl` / `apiV1Base`. No hardcoded legacy `gemini-api-*` URLs remain in Dart sources.

Success criteria:

- `GET /api/health` → `200`, `{ "success": true, "status": "ok" }`
- `POST /api/register` → `201`
- No `530` / `error code: 1016`

`ApiException` maps **530** to a user-facing “server temporarily unavailable” message in Arabic.
