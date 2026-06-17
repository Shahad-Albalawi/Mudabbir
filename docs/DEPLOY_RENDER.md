# Deploy Mudabbir Backend on Render

This guide deploys `backend/` as a public API for Flutter.

## 1) Create Web Service

1. Open [Render Dashboard](https://dashboard.render.com/).
2. Click **New** -> **Web Service**.
3. Connect your Git repo that contains `backend/`.
4. Render will detect `render.yaml` automatically. Approve it.

## 2) Add Environment Variables

In Render service -> **Environment**, add:

- `APP_ENV=production`
- `APP_DEBUG=false`
- `APP_URL=https://<your-render-domain>`
- `APP_KEY=<paste-a-generated-laravel-key>`
- `OPENAI_BASE_URL=https://integrate.api.nvidia.com/v1`
- `OPENAI_API_KEY=<your-nvidia-nvapi-key>`
- `OPENAI_MODEL=meta/llama-3.1-8b-instruct`
- `OPENAI_TIMEOUT_SECONDS=30`
- `OPENAI_CONNECT_TIMEOUT_SECONDS=10`
- `OPENAI_RETRIES=2`
- `OPENAI_RETRY_SLEEP_MS=250`
- `OPENAI_VERIFY_SSL=true`

Optional:

- `LOG_LEVEL=warning`

## 3) Generate APP_KEY

Use local project terminal:

```bash
php artisan key:generate --show
```

Copy the returned value (starts with `base64:`) into Render `APP_KEY`.

## 4) Verify Deployment

After deploy finishes, test:

- `GET https://<your-render-domain>/api/health` — must return `200` (public; used by Render health checks)
- `POST https://<your-render-domain>/api/register` — Sanctum auth (Phase 1+)
- `GET https://<your-render-domain>/api/expenses` — requires `Authorization: Bearer <token>`

Or run from repo root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1 -ApiBaseUrl "https://<your-render-domain>"
```

Legacy checks (now require auth):

- `GET /api/challenges`, `/api/expenses`, `/api/goals` → `401` without token is expected.

## 5) Connect Flutter

Set the API host in `frontend/config/release.json`, then build:

```bash
cd frontend
flutter build apk --release --dart-define-from-file=config/release.json
```

Or from repo root (optional custom URL):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build-release-apk.ps1 -ApiBaseUrl "https://<your-render-domain>"
```

For local development on the emulator:

```bash
flutter run --dart-define=USE_LOCAL_API=true
```
