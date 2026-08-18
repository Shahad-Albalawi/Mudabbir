# GitHub Secrets — Laravel Scheduler (budget push alerts)

The workflow `.github/workflows/laravel-scheduler.yml` runs `php artisan schedule:run` daily at **08:00 UTC** (11:00 Riyadh). Without secrets it skips quietly.

## 1. Open GitHub repository settings

1. Go to https://github.com/Shahad-Albalawi/Mudabbir  
2. **Settings** → **Secrets and variables** → **Actions**  
3. Click **New repository secret**

## 2. Required secrets

Copy values from **Render** → `mudabbir-backend-api` → **Environment**:

| Secret name | Render variable | Notes |
|-------------|-----------------|-------|
| `MUDABBIR_DATABASE_URL` | `DATABASE_URL` | Use the **pooled** Neon URL (with `-pooler`) |
| `MUDABBIR_APP_KEY` | `APP_KEY` | Must match production exactly |

## 3. Optional (push notifications)

| Secret name | Render variable |
|-------------|-----------------|
| `MUDABBIR_FCM_SERVER_KEY` | `FCM_SERVER_KEY` |

If omitted, scheduled budget checks still run; push alerts are skipped.

## 4. Test manually

1. GitHub → **Actions** → **Laravel Scheduler**  
2. **Run workflow** → Run  
3. Open the job log — expect `Running scheduled command` or budget job output

## 5. Troubleshooting

| Log message | Fix |
|-------------|-----|
| `Add GitHub secrets MUDABBIR_DATABASE_URL...` | Add both required secrets |
| Database connection error | Use pooled `DATABASE_URL`, check Neon is awake |
| `APP_KEY` invalid | Copy full `base64:...` key from Render |

See also: [BACKEND_CLOSURE.md](./BACKEND_CLOSURE.md) section 3.
