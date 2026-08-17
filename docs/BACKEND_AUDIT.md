# Backend Technical Audit — Mudabbir (Laravel)

**Date:** 2026-08-12  
**Scope:** `backend/` — Laravel 9 API  
**Branch reviewed:** `production-polish`  
**Method:** Static code review of controllers, services, models, migrations, routes, tests  
**Tone:** Honest assessment — not a marketing document

---

## Executive summary

The Mudabbir backend is **functional for a graduation/portfolio project** and shows deliberate structure (thin controllers, FormRequests, unified JSON envelope, rate limiting). It is **not production-grade** as-is because of a **hybrid JSON-file + SQLite storage model** that is fragile on Render, duplicated business logic across four `*Store` classes, and **authorization that relies on manual `user_id` checks** instead of Laravel Policies.

**Overall backend score: 5.5 / 10**

---

## 1. Architecture (Code structure)

**Score: 4 / 10**

### What is good

- **Controllers are thin.** Most delegate to `*Service` or `*Store` classes. Example: `AuthController` (64 lines) only orchestrates `AuthService` / `PasswordResetService`.
- **Dedicated services exist** for cross-cutting domains: `DashboardService`, `StatisticsService`, `ReportService`, `AuthService`, `PasswordResetService`, `HealthCheckService`, AI stack.
- **Shared traits** reduce duplication for JSON stores: `ManagesJsonFileStore`, `ResolvesSyncConflicts`, `UsesJsonStorePath`.

### Critical architectural problem: dual persistence

Financial data does **not** live in Eloquent/DB as the single source of truth.

| Domain | Primary storage | Secondary / read path |
|--------|-----------------|------------------------|
| Expenses | JSON file (`expenses.json`) via `ExpenseStore` | SQLite `expenses` table via `ExpenseDatabaseSync` + Eloquent (list/filter only) |
| Goals | JSON (`goals.json`) | None |
| Budgets | JSON (`budgets.json`) | None |
| Challenges | JSON (`challenges.json`) | None |
| Users, tokens, notifications, device tokens | SQLite | — |

**Consequences:**

1. **Render / ephemeral disks:** JSON files under `storage/app/` and SQLite are **lost on redeploy** unless a persistent volume is attached. User accounts survive; **all expenses/goals/budgets/challenges can vanish**.
2. **Consistency risk:** `ExpenseController::index()` reads from SQLite after `syncUser()`, but `show` / `update` / `destroy` use `ExpenseStore` (JSON). If sync fails silently, list vs detail can diverge.
3. **No real domain layer:** Goals, budgets, challenges have **no Eloquent models** — only arrays in JSON. Relationships, migrations, and query optimization cannot apply.

Relevant code:

```22:48:backend/app/Http/Controllers/Api/ExpenseController.php
    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $this->sync->syncUser($userId);   // full re-sync from JSON → DB on every list

        $paginator = Expense::query()
            ->forUser($userId)
            // ...
```

```31:49:backend/app/Services/ExpenseDatabaseSync.php
        return Expense::query()->updateOrCreate(
            ['id' => (int) $row['id']],   // keyed by global id, not (user_id, id)
            [
                'user_id' => (int) ($row['user_id'] ?? 0),
                // ...
```

### Business logic location

| Location | Lines (approx.) | Verdict |
|----------|-----------------|---------|
| `ChallengeStore.php` | 512 | **Fat service** — CRUD, invites, check-in, streaks, badges, leaderboard, templates |
| `GoalStore.php` | 293 | Fat — milestones, contributions, completion logic |
| `ExpenseStore.php` | 170 | Moderate |
| `BudgetStore.php` | 147 | Moderate |
| `StatisticsService.php` | 130 | Aggregation logic (acceptable) |
| `DashboardService.php` | 245 | Health score + behavior heuristics (acceptable but untested in isolation) |

**Controllers are not fat**, but **`ChallengeStore` and `GoalStore` are.** There are no Action classes or dedicated domain objects.

Example of non-trivial logic inside a store (not controller):

```255:271:backend/app/Services/GoalStore.php
    private function applyMilestoneProgress(array $goal): array
    {
        $current = (float) ($goal['current_amount'] ?? 0);
        $milestones = $goal['milestones'] ?? [];
        foreach ($milestones as $i => $milestone) {
            // achievement detection + timestamp updates
```

### Code duplication

The four `*Store` classes repeat the same pattern:

- `emptyDocument()` / `collectionKey()` / `all($userId)` filter / `find($id, $userId)` loop / `delete` filter
- `filterUpdatable()` + `normalize*()` per entity
- Conflict resolution via `ResolvesSyncConflicts` (expenses, goals, budgets only)

**Example:** `ExpenseStore::find()` and `GoalStore::find()` are structurally identical (loop + `user_id` check). A generic `JsonDocumentRepository` or full Eloquent migration would remove ~400 duplicated lines.

### Models and relationships

- `Expense` — **good:** `user()` relationship, query scopes (`forUser`, `byDateRange`, `byCategory`, etc.).
- `User` — **incomplete:** no `hasMany` for expenses, notifications, or device tokens.
- **Goals, budgets, challenges — no models at all.**

Manual array filtering replaces Eloquent everywhere outside expenses list:

```52:62:backend/app/Services/ExpenseStore.php
    public function find(int $id, int $userId): ?array
    {
        return $this->mutateStore(function (array $data) use ($id, $userId): ?array {
            foreach ($data['expenses'] as $expense) {
                if ((int) $expense['id'] === $id && (int) ($expense['user_id'] ?? 0) === $userId) {
```

### Concurrency

- `ExpenseStore`, `GoalStore`, `BudgetStore` use `ManagesJsonFileStore` with **`flock(LOCK_EX)`** — good.
- `ChallengeStore` uses plain `File::get` / `File::put` **without locking** — race conditions under concurrent writes.

```608:612:backend/app/Services/ChallengeStore.php
    private function write(array $payload): void
    {
        File::ensureDirectoryExists(dirname($this->path));
        File::put($this->path, json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    }
```

---

## 2. Validation and security

**Score: 6 / 10**

### FormRequest coverage

| Endpoint | FormRequest? | Notes |
|----------|--------------|-------|
| `POST /register`, `/login` | ✅ | `RegisterRequest`, `LoginRequest` |
| `POST /auth/forgot-password`, `/reset-password` | ✅ | |
| `POST /expenses`, `PUT /expenses/{id}` | ✅ | |
| `POST/PUT /goals`, milestones, contributions | ✅ | |
| `POST/PUT /budgets` | ✅ | |
| `POST/PUT /challenges`, invite, respond, progress | ✅ | |
| `POST /ai/chat`, `/generate-content` | ✅ | |
| `POST /device-tokens` | ✅ | |
| `DELETE /device-tokens` | ⚠️ | Inline `$request->validate()` in controller |
| `POST /notifications/test-push` | ⚠️ | Inline validate in `PushTestController` |
| `GET /expenses` (query: from, to, category, min, max, sort, per_page) | ⚠️ | Manual checks in controller only (`sort` whitelist) — **no max length / date format validation** |
| `GET /reports/monthly?month=` | ⚠️ | Regex in controller, no FormRequest |
| `POST /challenges/{id}/check-in` | ❌ | Raw `Request` — no body rules (OK) but no dedicated request class |
| `PATCH /challenges/{id}/status` (toggleStatus) | ❌ | No FormRequest |
| `DELETE /challenges/{id}/participants/{userId}` | ❌ | Route param `userId` not validated (integer coercion only) |
| `PATCH /notifications/{id}/read` | ❌ | No FormRequest (low risk) |
| `GET /statistics`, `/dashboard` | — | No user input |

**All FormRequests return `authorize(): true`.** Authorization is **never** in FormRequest — only in Store layer.

### IDOR (Insecure Direct Object Reference)

**No Laravel Policies** (`backend/app/Policies/` is empty; `AuthServiceProvider` has commented placeholder).

Authorization pattern: pass `$request->user()->id` into `*Store::find($id, $userId)` or query `where('user_id', $userId)`.

#### Endpoints audited

| Endpoint | Isolation mechanism | IDOR risk |
|----------|---------------------|-----------|
| `GET/PUT/DELETE /expenses/{id}` | `ExpenseStore::find/update/delete($id, $userId)` | ✅ Low — returns 404 for other users |
| `GET /expenses` | `Expense::forUser($userId)` | ✅ |
| `GET/PUT/DELETE /goals/{id}` | `GoalStore` + `user_id` | ✅ |
| `GET/PUT/DELETE /budgets/{id}` | `BudgetStore` + `user_id` | ✅ (not covered by tests) |
| `GET /challenges/{id}` | `userCanAccess()` — creator or **accepted** participant | ✅ By design; pending invitees use `/invitations/pending` |
| `POST /challenges/{id}/respond` | Matches **email** on pending participant (avoids id collision) | ✅ Thoughtful — see comment at `ChallengeStore.php:244-246` |
| `DELETE /challenges/{id}/participants/{userId}` | Creator can remove others; non-creator can only remove self | ✅ |
| `GET /challenges/{id}/leaderboard` | Requires `find($id, $userId)` first | ✅ |
| `PATCH /notifications/{id}/read` | `where('user_id', $userId)->whereKey($id)` | ✅ (not tested) |
| `GET /statistics`, `/dashboard`, `/reports/monthly` | `$userId` from auth only | ✅ |
| `POST /notifications/test-push` | Pushes only to `$request->user()` | ✅ No IDOR — but **abuse vector** (any user can spam FCM) |

#### Test coverage for isolation

`UserDataIsolationTest` covers:

- ✅ Expenses (list + show + update + delete cross-user)
- ✅ Goals (show + update + delete cross-user)
- ✅ Monthly report totals per user

**Missing tests:**

- ❌ Budgets cross-user access
- ❌ Notifications cross-user `markRead`
- ❌ Challenges cross-user `show` / `update` / `destroy`
- ❌ Device token deletion with another user's token string

**Verdict:** IDOR defenses are **implemented correctly in code** for the main CRUD paths, but **not enforced via Policies** and **not fully regression-tested**. One mistake in a new endpoint would go unnoticed.

### SQL injection

- **No vulnerable raw SQL found** in application code.
- Only safe usage: `DB::select('select 1 as ok')` in `HealthCheckService.php:58` (no user input).
- All Eloquent / query builder usage uses parameter binding.

### Other security notes

| Topic | Status |
|-------|--------|
| Rate limiting | ✅ Login, register, password reset, AI, challenges-write — `RouteServiceProvider` |
| Login lockout | ✅ `AuthService` — 5 failures / 60s per email+IP |
| Password reset enumeration | ✅ Silent when email unknown — `PasswordResetService::sendResetCode` |
| Sanctum token rotation | ✅ Single `mudabbir-mobile` token re-issued on login |
| `POST /notifications/test-push` | ⚠️ Should be disabled or admin-only in production |
| CORS / CSRF | API routes — stateless Sanctum (expected) |

---

## 3. Database queries and performance

**Score: 5 / 10**

### N+1 queries (Eloquent)

**No classic Eloquent N+1** (`->with()` is essentially unused) because most reads are **full JSON file loads**, not relational queries.

That is worse for scale: every `expenseStore->all($userId)` reads and decodes the **entire** expenses file, then filters in PHP.

### Performance smells (with file references)

1. **Full sync on every expense list**

```22:25:backend/app/Http/Controllers/Api/ExpenseController.php
        $this->sync->syncUser($userId);   // O(n) upserts per list request
```

2. **Double load of all expenses in one request**

```39:86:backend/app/Services/StatisticsService.php
        foreach ($this->expenseStore->all($userId) as $row) { /* first pass */ }
        // ...
        $expenses = $this->expenseStore->all($userId);   // second full read for budgets
```

3. **`CheckBudgetLimitsJob`** — for each budget, calls `expenseStore->all($userId)` again (nested loop over all users' budgets × all user expenses).

4. **ChallengeStore::read()`** — no locking; loads entire challenges file for every operation.

### Indexes

**Expenses table — good:**

```27:29:backend/database/migrations/2026_06_23_000001_create_expenses_table.php
            $table->index(['user_id', 'date']);
            $table->index(['user_id', 'category_id']);
            $table->index(['user_id', 'amount']);
```

**User notifications — good:** `(user_id, read_at)`.

**Weak / questionable:**

```11:17:backend/database/migrations/2026_06_22_000001_add_performance_indexes.php
        Schema::table('users', function (Blueprint $table) {
            $table->index('created_at');   // unused in any API query found
        });
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->index('created_at');   // unused in any API query found
        });
```

These indexes do not match actual query patterns (`users.email` for login is unindexed beyond unique constraint — acceptable at small scale).

**Goals/budgets/challenges:** No DB tables → **no indexes possible** until migrated off JSON.

---

## 4. API response consistency

**Score: 7 / 10**

### Unified envelope (major strength)

`App\Helpers\ApiResponse` defines:

```json
{
  "success": true|false,
  "data": ...,
  "message": "...",
  "errors": null|{...},
  "meta": { "timestamp", "version" }
}
```

Controllers use `ApiResponse` trait → helper. **Most endpoints follow this.**

### Inconsistencies

| Case | Issue |
|------|-------|
| **409 Conflict** | Adds top-level `"conflict": true` outside standard envelope fields — `ApiResponse::conflict()` |
| **AI coded errors** | `GenerateContentController` adds `"status": "error"` via `codedError()` |
| **AI streaming** | `POST /ai/chat` with `stream=true` returns **SSE**, not JSON envelope — by design but clients must handle two formats |
| **Health check** | Returns `success: true` even when `data.status` is `degraded` — HTTP 200 if DB+storage OK |
| **Pagination meta** | `paginated()` merges pagination into `meta` — good, but different from non-paginated responses |
| **Resources usage** | `ExpenseResource` / `GoalResource` used for expenses/goals; **budgets and challenges return raw arrays** from stores |
| **Mixed Arabic/English messages** | e.g. `created()` default message Arabic; many controller messages English (`'Deleted'`, `'Expense not found'`) |

Example — budgets skip Resource layer:

```20:21:backend/app/Http/Controllers/Api/BudgetController.php
        return $this->success($this->store->all($userId));   // raw array, no BudgetResource
```

---

## 5. Error handling

**Score: 7 / 10**

### Global handler — good

`App\Exceptions\Handler` maps API exceptions to envelope:

- `ValidationException` → 422 + Arabic message + field errors
- `AuthenticationException` → 401
- `NotFoundHttpException` → 404
- `ThrottleRequestsException` → 429
- Production → generic 500 (no stack trace leak)

Tests: `ApiExceptionHandlerTest` confirms 401/404/422 shapes.

### Gaps

1. **`APP_DEBUG=true`** — handler returns `null` and falls through to Laravel default (may expose stack traces). Ensure `APP_DEBUG=false` on Render (already in `render.yaml`).
2. **AI controllers** catch `Throwable` locally — good for UX, but duplicates handler logic (`AiChatController`, `GenerateContentController`).
3. **JSON store corruption** — `ManagesJsonFileStore` throws `RuntimeException` → likely **500 generic** without actionable client message.
4. **`ChallengeStore::read()`** on corrupt file **silently returns empty array** instead of failing — can hide data loss.

```596:603:backend/app/Services/ChallengeStore.php
        if (! is_array($decoded) || ! isset($decoded['challenges'])) {
            return [
                'next_challenge_id' => 1,
                'challenges' => [],
            ];   // silent reset — dangerous
        }
```

---

## 6. Naming, clarity, dead code

**Score: 6 / 10**

### Clarity

| Aspect | Verdict |
|--------|---------|
| Controller / Service naming | Clear and predictable |
| `*Store` vs `*Service` | Confusing — `Store` implies DB but means JSON file repository |
| Route duplication | `POST /challenges/{id}/invite` **and** `/invitations` — same handler (`api.php:61-62`) |
| `GenerateContentController` | Sets `message` to AI reply text **and** duplicates `meta` in `extra` — confusing API contract |

### Dead / low-value code

| Item | Notes |
|------|-------|
| `GeminiService` | **Used** via `AiCoachService` when `AI_PROVIDER=gemini` — not dead |
| Laravel Policies | Scaffold commented out, never implemented |
| `users.created_at` index migration | No matching query pattern found |
| `backend/render.yaml` vs root `render.yaml` | Duplicate deploy configs — maintenance burden |

No large blocks of unused controllers or routes were found.

---

## 7. Overall scores

| Area | Score | Reason (brief) |
|------|-------|----------------|
| **Architecture** | **4/10** | JSON-file primary storage + SQLite sidecar; fat stores; no Policies; not cloud-durable |
| **Validation & security** | **6/10** | Good FormRequests on writes and rate limits; IDOR guarded in stores but no Policies; gaps in tests |
| **Database / queries** | **5/10** | Good indexes on `expenses`; full-file reads dominate; sync-on-list; double `all()` in statistics |
| **API consistency** | **7/10** | Strong `ApiResponse` envelope; exceptions for SSE, conflict, coded AI errors, mixed languages |
| **Error handling** | **7/10** | Solid global handler; corrupt challenge JSON silently resets |
| **Naming & clarity** | **6/10** | Readable code; misleading `*Store` naming; minor duplication |

**Weighted overall: ~5.5 / 10** for production readiness  
**~7 / 10** as a structured student/portfolio API with tests

---

## Top 5 issues to fix first (priority order)

### 1. JSON file storage on ephemeral hosting (CRITICAL)

All financial data in `storage/app/*.json` is **not durable** on Render free tier. Redeploy = data loss. SQLite has the same problem.

**Fix:** Migrate expenses, goals, budgets, challenges to **proper Eloquent models + migrations** (Postgres on Render). Remove JSON stores or restrict to local dev only.

### 2. Dual write path for expenses (HIGH)

JSON is source of truth; SQLite is a read replica synced on every list. Risk of drift and unnecessary load.

**Fix:** Single source of truth in DB; drop `ExpenseStore` JSON layer or make JSON export-only.

### 3. `ChallengeStore` lacks file locking (HIGH)

Unlike other stores, concurrent invite/check-in/progress updates can corrupt `challenges.json`.

**Fix:** Use `ManagesJsonFileStore` trait or move to DB.

### 4. Authorization via convention, not framework (MEDIUM)

No Policies; every new endpoint must remember `user_id` scoping manually.

**Fix:** Add `ExpensePolicy`, `GoalPolicy`, `BudgetPolicy`, `ChallengePolicy`; use `$this->authorize()` in controllers.

### 5. Incomplete isolation & production test endpoints (MEDIUM)

`UserDataIsolationTest` does not cover budgets, notifications, challenges. `POST /notifications/test-push` is available to any authenticated user in production.

**Fix:** Extend IDOR tests; gate test-push behind `APP_ENV=local` or feature flag.

---

## Top 3 genuine strengths

1. **Thin controllers + centralized `ApiResponse` envelope** — easy to learn and extend; exception handler gives consistent JSON errors with Arabic validation messages.

2. **Security-aware auth flows** — Sanctum single-token pattern, login rate limit + lockout, password-reset anti-enumeration, AI endpoint throttling (minute + hour).

3. **Thoughtful details in complex domains** — expense update conflicts (`409` + server version), challenge invite matching by email (not provisional id), `ManagesJsonFileStore` file locking with corrupt-file backup for expenses/goals/budgets.

---

## Appendix A — Controller size reference

| Controller | Lines | Business logic in controller? |
|------------|-------|------------------------------|
| `ChallengeController` | 163 | No — delegates to `ChallengeStore` |
| `GoalController` | 86 | No |
| `ExpenseController` | 85 | Minor — query param whitelist for `sort` |
| `GenerateContentController` | 65 | try/catch only |
| `BudgetController` | 61 | No |
| `AuthController` | 51 | No |
| Others | &lt; 50 | No |

**No controller is dangerously fat.** Complexity lives in `*Store` services.

---

## Appendix B — Test suite snapshot

21 feature test files covering auth, expenses, goals, budgets, challenges, health, rate limiting, password reset, device tokens, API exception handler, user isolation (partial).

**Not run during this audit** (PHP environment unavailable on review machine). Tests use `RefreshDatabase` + isolated JSON store subdirectory per `TestCase::setUp()`.

---

## Appendix C — Recommended migration path (if moving to production)

1. **Phase 1:** Postgres + Eloquent for expenses (remove JSON + sync).
2. **Phase 2:** Models for goals, budgets; migrate JSON → DB seed command.
3. **Phase 3:** Challenges to DB; adopt `ManagesJsonFileStore` locking or transactions.
4. **Phase 4:** Policies + complete IDOR test matrix.
5. **Phase 5:** Remove `/notifications/test-push` from production routes; add `BudgetResource` / `ChallengeResource` for consistent API output.

---

*This document reflects the codebase as of 2026-08-12. Re-audit after major storage migration.*
