# Migration safety net — JSON backups & branch strategy

**Do not start DB migration until you have 3 independent copies of JSON data.**

---

## 1. Backup script

```bash
# From repo root (Git Bash / Linux / macOS)
chmod +x scripts/backup-json.sh
./scripts/backup-json.sh
```

Default output (outside repo):

```text
~/mudabbir-json-backups/mudabbir-json-YYYY-MM-DD-HHMMSSZ.tar.gz
```

Custom directory:

```bash
MUDABBIR_BACKUP_DIR="/path/outside/project" ./scripts/backup-json.sh
```

Includes every `*.json` under `backend/storage/app/` (expenses, goals, budgets, challenges, and subdirs).

Each run also writes a `.sha256` sidecar for integrity checks.

---

## 2. Three copies rule

| Copy | Where | How |
|------|--------|-----|
| **A — Server** | Render shell / production host | Run `scripts/backup-json.sh` on the server and download the `.tar.gz` |
| **B — Your PC** | Outside the git repo | Default `~/mudabbir-json-backups/` or `Documents\Mudabbir-JSON-Backup\` |
| **C — Off-site** | GitHub Actions artifact | Push this branch → Actions → **Backup JSON stores** → Run workflow → download artifact |

Optional fourth: attach the same `.tar.gz` to a **GitHub Release** (manual upload).

---

## 3. Restore (if needed)

```bash
mkdir -p backend/storage/app
tar -xzf mudabbir-json-YYYY-MM-DD-HHMMSSZ.tar.gz -C /tmp/restore
cp -a /tmp/restore/storage-app/. backend/storage/app/
```

Verify checksum:

```bash
sha256sum -c mudabbir-json-....tar.gz.sha256
```

---

## 4. Git branches (one branch per migration step)

Create from `production-polish` (or current baseline) **before** editing schema:

```bash
git checkout production-polish
git branch migrate/expenses
git branch migrate/goals
git branch migrate/budgets
git branch migrate/challenges
```

Workflow:

1. `git checkout migrate/expenses` → implement + test → merge when stable  
2. `git checkout migrate/goals` → rebase on updated base → implement → merge  
3. Repeat for budgets, challenges  

If a step fails: `git checkout production-polish` or reset the feature branch — JSON backups remain your data safety net.

---

## 5. Pre-migration checklist

- [ ] `./scripts/backup-json.sh` run locally  
- [ ] Archive copied to a folder **outside** the repo on your PC  
- [ ] Same backup run on **Render** (if production has real data) and downloaded  
- [ ] GitHub Actions **Backup JSON stores** workflow run; artifact downloaded  
- [ ] Branches `migrate/expenses`, `migrate/goals`, `migrate/budgets`, `migrate/challenges` exist  
- [ ] SHA256 verified on all archives  

Only then start `migrate/expenses`.
