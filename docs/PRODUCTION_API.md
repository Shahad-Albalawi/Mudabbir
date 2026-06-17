# Production API — diagnosis & remediation

Current default production host (Flutter `release.json` / `api_constants.dart`):

```text
https://gemini-api-s-challenges-uvxa39.laravel.cloud
```

## Diagnosis (2026-06-17)

| Check | Result |
|-------|--------|
| Public DNS (Cloudflare 1.1.1.1) | **OK** — `A` → `103.133.1.1`, `103.133.1.2` (Cloudflare anycast) |
| HTTPS to `/` and `/api/login` | **FAIL** — `HTTP 530`, body `error code: 1016` |
| `Server` header | `cloudflare` |
| Cloudflare Tunnel on this repo | **None** — not used; Laravel Cloud proxies via Cloudflare SaaS |
| Direct origin bypass | **Not possible** — no public origin IP; traffic must go through `*.laravel.cloud` |

### Root cause

**Cloudflare error 1016 (shown as HTTP 530)** means Cloudflare’s edge received the request for `gemini-api-s-challenges-uvxa39.laravel.cloud` but **cannot resolve or route to the Laravel Cloud origin** behind that hostname.

This is **not** a Flutter or Laravel application bug. Typical causes on Laravel Cloud:

1. Environment **deleted**, **paused**, or **never finished deploying**
2. Failed / rolled-back deployment leaving a broken origin mapping
3. Laravel Cloud internal origin hostname no longer exists (stale `*.laravel.cloud` URL in the app)

The app’s DNS resolves to Cloudflare, but the **origin behind Laravel Cloud is down or misconfigured**.

## Fixes (choose one)

### Option A — Restore Laravel Cloud (keep current URL)

**Step-by-step (Arabic):** see [DEPLOY_LARAVEL_CLOUD.md](./DEPLOY_LARAVEL_CLOUD.md).

1. Sign in to [Laravel Cloud](https://cloud.laravel.com/).
2. Open the project that owned `gemini-api-s-challenges-uvxa39`.
3. Confirm the environment is **Running** (not paused/deleted).
4. **Redeploy** the latest commit from `backend/`.
5. Ensure env vars are set: `APP_KEY`, `APP_URL=https://gemini-api-s-challenges-uvxa39.laravel.cloud`, `APP_ENV=production`, `APP_DEBUG=false`.
6. Run migrations on deploy (users + Sanctum tokens need SQLite/MySQL).
7. Verify:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1 `
     -ApiBaseUrl "https://gemini-api-s-challenges-uvxa39.laravel.cloud"
   ```

   Expect `HTTP 200` on `/api/health`.

If the environment was deleted, create a **new** Laravel Cloud app and update `frontend/config/release.json` with the new `*.laravel.cloud` URL.

### Option B — Deploy on Render (recommended fallback)

Render is already configured via `backend/render.yaml`.

1. Follow [DEPLOY_RENDER.md](./DEPLOY_RENDER.md).
2. Set `APP_KEY`, `APP_URL`, and AI keys in Render **Environment**.
3. After deploy, note your `https://<service>.onrender.com` URL.
4. Point Flutter at the new host:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/build-release-apk.ps1 `
     -ApiBaseUrl "https://<your-service>.onrender.com"
   ```

5. Run the health check script against the new URL.

**Note:** After Phase 1 auth, `/api/challenges` requires a Bearer token. Render health checks use **`/api/health`** (public).

## Ongoing verification

From repo root:

```powershell
# Default (Laravel Cloud URL in release.json)
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1

# Custom host
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1 -ApiBaseUrl "https://your-api.example.com"
```

Success criteria:

- `GET /api/health` → `200`, `{ "success": true, "status": "ok" }`
- `POST /api/register` → `201` (with valid body)
- No `530` / `error code: 1016`

## Flutter client behavior

`ApiException` already maps **530** to a user-facing Arabic-friendly “server temporarily unavailable” message. Fixing production DNS/origin is required for sync, login, and challenges to work in release builds.
