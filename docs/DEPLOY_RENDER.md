# Deploy Mudabbir Backend on Render

This guide deploys `apps/backend` as a public API for Flutter.

## 1) Create Web Service

1. Open [Render Dashboard](https://dashboard.render.com/).
2. Click **New** -> **Web Service**.
3. Connect your Git repo that contains `apps/backend`.
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

- `GET https://<your-render-domain>/api/challenges`
- `POST https://<your-render-domain>/api/generate-content`

Expected shape:

```json
{ "success": true, "data": [] }
```

## 5) Connect Flutter

Run app with:

```bash
flutter run --dart-define=CHALLENGES_API_BASE_URL=https://<your-render-domain>/api
```

If chatbot should also use this backend, update chatbot base URL to the same domain.
