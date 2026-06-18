# Production API — diagnosis & remediation

Current default production host (Flutter `release.json` / `api_constants.dart`):

```text
https://laravel-main-nb0wjv.free.laravel.cloud
```

This is the **Laravel Cloud vanity domain** shown as **Connected** in the dashboard (Domains).

Legacy hosts (do not use):

```text
https://laravel-main-nb0wjv.laravel.cloud
https://gemini-api-s-challenges-uvxa39.laravel.cloud
```

## Status (2026-06-18)

| Check | Result |
|-------|--------|
| Deploy `fc36dcf` on branch `laravel-cloud` | **Deployed** (dashboard) |
| Domain `laravel-main-nb0wjv.free.laravel.cloud` | **Connected** (dashboard) |
| Public DNS propagation | May take up to ~15 minutes after first connect |

Verify from your machine:

```powershell
curl.exe -sS "https://laravel-main-nb0wjv.free.laravel.cloud/api/health"
```

Expect **200** and `{ "success": true, "status": "ok" }`.

Or:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1
```

## Laravel Cloud setup

| Setting | Value |
|---------|--------|
| Repository | `Shahad-Albalawi/Mudabbir` |
| Branch | `laravel-cloud` |
| Build | `bash cloud-build.sh` |
| Deploy | `bash cloud-deploy.sh` |
| `APP_URL` | `https://laravel-main-nb0wjv.free.laravel.cloud` |

Database: `cloud-env.sh` auto-uses **SQLite** when Cloud MySQL (`forge`) is not attached.

## Flutter — locked to backend

| Build | API host |
|-------|----------|
| **Release** | `https://laravel-main-nb0wjv.free.laravel.cloud` |
| **Debug** | `http://10.0.2.2:8000` |
| **Override** | `--dart-define=API_BASE_URL=...` |

All HTTP uses `ApiConstants.baseUrl` / Dio.

## Troubleshooting

| Symptom | Action |
|---------|--------|
| HTTP 530 / 1016 | Wait for DNS; confirm env **Running**; **Restart** + Redeploy |
| `Connection refused` + `forge` on migrate | Fixed in `cloud-env.sh` — redeploy latest `laravel-cloud` |
| `/api/health` 404 | Wrong project deployed — confirm commit is `fc36dcf`+ from `laravel-cloud` |

Fallback hosting: [DEPLOY_RENDER.md](./DEPLOY_RENDER.md).
