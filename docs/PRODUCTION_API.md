# Production API

**Live host (Render):**

```text
https://mudabbir-backend-api.onrender.com
```

## Verify

```powershell
curl.exe -sS "https://mudabbir-backend-api.onrender.com/api/health"
```

Expect **200** and `{ "success": true, "status": "ok" }`.

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1
```

## Flutter

| Build | API |
|-------|-----|
| Release | `https://mudabbir-backend-api.onrender.com` via `release.json` |
| Debug | `http://10.0.2.2:8000` |

## Notes

- **Free Render:** instance sleeps when idle; first request after sleep can take ~50 seconds.
- Laravel Cloud (`laravel-main-nb0wjv`) had domain/routing issues — Render is the active production backend.
- Deploy guide: [DEPLOY_RENDER_AR.md](./DEPLOY_RENDER_AR.md)
